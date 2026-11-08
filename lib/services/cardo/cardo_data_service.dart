import 'dart:async';
import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../database/task_tables.dart';
import 'cardo_scoring_service.dart';

/// Transactional write boundary for lifecycle, actual time, DAG and observations.
class CardoDataService {
  final AppDatabase db;
  final CardoScoringService scoring;
  final DateTime Function() clock;
  CardoDataService(this.db, this.scoring, {DateTime Function()? clock})
    : clock = clock ?? DateTime.now;

  Future<Task> _task(int id) =>
      (db.select(db.tasks)..where((t) => t.id.equals(id))).getSingle();

  Future<void> start(int id) => db.transaction(() async {
    final task = await _task(id);
    if (!{0, 2}.contains(task.status)) {
      throw StateError('Task cannot start in this status');
    }
    if (await _blocked(id)) throw StateError('Unfinished prerequisite');
    final now = clock().toUtc();
    await (db.update(db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(startedAt: Value(task.startedAt ?? now)),
    );
    await _event(id, 'started', now);
  });

  /// Add only explicitly observed effective whole minutes. Null stays unknown
  /// until the first observation. Retry the same observation with the same key.
  Future<void> addUsedTime(
    int id,
    int minutes, {
    required String idempotencyKey,
  }) => db.transaction(() async {
    if (idempotencyKey.trim().isEmpty || idempotencyKey.length > 128) {
      throw ArgumentError("Expected an observation key of 1-128 characters");
    }
    if (minutes <= 0) {
      throw ArgumentError.value(minutes, 'minutes', 'must be positive');
    }
    // Acquire the SQLite write lock before reading any snapshot. The unique
    // index makes retries serialize even across independent DB connections.
    final inserted = await db.customUpdate(
      'INSERT INTO task_events(task_id, kind, occurred_at, minutes, idempotency_key) '
      "VALUES (?, 'time_logged', ?, ?, ?) ON CONFLICT(task_id, idempotency_key) DO NOTHING",
      variables: [
        Variable(id),
        Variable(clock().toUtc()),
        Variable(minutes),
        Variable(idempotencyKey),
      ],
      updates: {db.taskEvents},
    );
    if (inserted == 0) {
      final previous =
          await (db.select(db.taskEvents)..where(
                (e) =>
                    e.taskId.equals(id) &
                    e.idempotencyKey.equals(idempotencyKey),
              ))
              .getSingle();
      if (previous.kind != 'time_logged' || previous.minutes != minutes) {
        throw StateError('Idempotency key reused with different payload');
      }
      return;
    }
    final task = await _task(id);
    if (!{0, 2}.contains(task.status)) throw StateError('Task is not active');
    await (db.update(db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(usedTime: Value((task.usedTime ?? 0) + minutes)),
    );
    await (db.update(db.taskEvents)..where(
          (e) => e.taskId.equals(id) & e.idempotencyKey.equals(idempotencyKey),
        ))
        .write(TaskEventsCompanion(estimatedMinutes: Value(_estimate(task))));
  });

  Future<void> complete(int id) => db.transaction(() async {
    final task = await _task(id);
    TaskLifecycle.requireTransition(task.status, 1);
    if (await _blocked(id)) throw StateError('Unfinished prerequisite');
    await db.taskDao.editTask(
      id: id,
      status: const Value(1),
      occurredAt: clock(),
    );
  });
  Future<void> reopen(int id) => db.transaction(() async {
    final task = await _task(id);
    if (task.status != 1) throw StateError('Only completed tasks can reopen');
    TaskLifecycle.requireTransition(task.status, 0);
    await db.taskDao.editTask(
      id: id,
      status: const Value(0),
      occurredAt: clock(),
    );
  });
  Future<void> fail(int id, String reason) => db.transaction(() async {
    final task = await _task(id);
    if (!{0, 2}.contains(task.status)) {
      throw StateError('Task is not active');
    }
    if (reason.trim().isEmpty) throw ArgumentError('Failure reason required');
    await db
        .into(db.taskEvents)
        .insert(
          TaskEventsCompanion.insert(
            taskId: id,
            kind: 'failed',
            occurredAt: clock().toUtc(),
            reason: Value(reason),
          ),
        );
  });
  Future<void> feedback(int id, String kind, {required int configRevision}) =>
      db.transaction(() async {
        if (!['exposed', 'accepted', 'ignored'].contains(kind)) {
          throw ArgumentError('Unknown feedback kind');
        }
        await _task(id);
        await db
            .into(db.taskEvents)
            .insert(
              TaskEventsCompanion.insert(
                taskId: id,
                kind: kind,
                occurredAt: clock().toUtc(),
                configRevision: Value(configRevision),
              ),
            );
      });
  Future<void> setContext(
    int id, {
    required DateTime expiresAt,
    bool? resourcesReady,
    int? availableMinutes,
    double? energyMatch,
    double? goalImpact,
  }) => db.transaction(() async {
    await _task(id);
    if (!expiresAt.isAfter(clock())) {
      throw ArgumentError('Context must expire in the future');
    }
    if (availableMinutes != null && availableMinutes < 0) {
      throw ArgumentError('Negative availability');
    }
    for (final v in [energyMatch, goalImpact]) {
      if (v != null && (!v.isFinite || v < 0 || v > 1)) {
        throw ArgumentError('Expected normalized value');
      }
    }
    await db
        .into(db.taskContexts)
        .insertOnConflictUpdate(
          TaskContextsCompanion.insert(
            taskId: Value(id),
            expiresAt: expiresAt.toUtc(),
            resourcesReady: Value(resourcesReady),
            availableMinutes: Value(availableMinutes),
            energyMatch: Value(energyMatch),
            goalImpact: Value(goalImpact),
          ),
        );
  });

  Future<void> addDependency(int predecessor, int successor) =>
      db.transaction(() async {
        await _task(predecessor);
        await _task(successor);
        final edges = await db.select(db.taskDependencies).get();
        final graph = <int, List<int>>{};
        for (final e in edges) {
          (graph[e.predecessor] ??= []).add(e.successor);
        }
        bool reaches(int from, int to, Set<int> seen) =>
            from == to ||
            (seen.add(from) &&
                (graph[from] ?? []).any((next) => reaches(next, to, seen)));
        if (reaches(successor, predecessor, {})) {
          throw StateError('dependency_cycle');
        }
        await db
            .into(db.taskDependencies)
            .insert(
              TaskDependenciesCompanion.insert(
                predecessor: predecessor,
                successor: successor,
              ),
              mode: InsertMode.insertOrIgnore,
            );
        await (db.update(db.tasks)
              ..where((t) => t.id.isIn([predecessor, successor])))
            .write(const TasksCompanion(dependencyGraphKnown: Value(true)));
      });

  /// Explicitly confirm the recorded graph for an imported/legacy task, including empty.
  Future<void> confirmDependencyGraph(int id) => db.transaction(() async {
    await _task(id);
    await (db.update(db.tasks)..where((t) => t.id.equals(id))).write(
      const TasksCompanion(dependencyGraphKnown: Value(true)),
    );
  });

  Future<List<TaskDependency>> getDependencies() =>
      db.select(db.taskDependencies).get();

  /// Stable cursor over observations; avoids loading an unbounded history.
  Future<List<TaskEvent>> eventPage(
    int taskId, {
    int afterId = 0,
    int limit = 100,
  }) {
    if (afterId < 0 || limit < 1 || limit > 1000) {
      throw ArgumentError('Invalid page');
    }
    return (db.select(db.taskEvents)
          ..where(
            (e) => e.taskId.equals(taskId) & e.id.isBiggerThanValue(afterId),
          )
          ..orderBy([(e) => OrderingTerm.asc(e.id)])
          ..limit(limit))
        .get();
  }

  Future<void> removeDependency(int predecessor, int successor) =>
      (db.delete(db.taskDependencies)..where(
            (e) =>
                e.predecessor.equals(predecessor) &
                e.successor.equals(successor),
          ))
          .go();
  Future<bool> _blocked(int id) async {
    final edges = await (db.select(
      db.taskDependencies,
    )..where((e) => e.successor.equals(id))).get();
    for (final e in edges) {
      if ((await _task(e.predecessor)).status != 1) return true;
    }
    return false;
  }

  Future<void> _event(int id, String kind, DateTime now) => db
      .into(db.taskEvents)
      .insert(
        TaskEventsCompanion.insert(taskId: id, kind: kind, occurredAt: now),
      );
  int? _estimate(Task t) =>
      t.estHour != null &&
          t.estHour! >= 0 &&
          t.estMinute != null &&
          t.estMinute! >= 0 &&
          t.estMinute! < 60
      ? t.estHour! * 60 + t.estMinute!
      : null;

  /// Consistent DB snapshot; critical path sums remaining estimated downstream
  /// work along the longest branch. Missing estimates propagate as unknown.
  Future<List<CardoResult>> calculate({
    DateTime? now,
    int afterId = 0,
    int? limit,
  }) => db.transaction(() async {
    if (afterId < 0 || (limit != null && (limit < 1 || limit > 1000))) {
      throw ArgumentError('Invalid page; limit must be 1-1000');
    }
    final instant = (now ?? clock()).toUtc();
    final tasks = await db.select(db.tasks).get();
    final edges = await db.select(db.taskDependencies).get();
    final eventStats = await db
        .customSelect(
          """
      SELECT task_id,
        SUM(kind = 'completed') AS successes,
        SUM(kind IN ('completed', 'failed')) AS attempts,
        SUM(kind = 'accepted') AS accepted,
        SUM(kind IN ('accepted','ignored','priority_changed')) AS feedback_count
      FROM task_events GROUP BY task_id
    """,
          readsFrom: {db.taskEvents},
        )
        .get();
    final statsById = {
      for (final row in eventStats) row.read<int>('task_id'): row,
    };
    final efficiency = await db
        .customSelect(
          """
      SELECT AVG(MIN(1.0, 1.0 * estimated_minutes / minutes)) AS efficiency
      FROM task_events WHERE kind = 'completed' AND minutes > 0 AND estimated_minutes > 0
    """,
          readsFrom: {db.taskEvents},
        )
        .getSingle();
    final contexts = await db.select(db.taskContexts).get();
    final contextById = {
      for (final c in contexts)
        if (c.expiresAt.isAfter(instant)) c.taskId: c,
    };
    final blockedIds = <int>{};
    final byId = {for (final t in tasks) t.id: t};
    final children = <int, List<int>>{};
    for (final e in edges) {
      (children[e.predecessor] ??= []).add(e.successor);
      if (byId[e.predecessor]?.status != 1) blockedIds.add(e.successor);
    }
    final memo = <int, double?>{};
    double? path(int id, Set<int> visiting) {
      if (memo.containsKey(id)) return memo[id];
      if (byId[id]?.dependencyGraphKnown != true) return memo[id] = null;
      if (!visiting.add(id)) return null;
      double longest = 0;
      for (final child in children[id] ?? <int>[]) {
        final t = byId[child];
        if (t == null) return null;
        if (t.status == 1) continue;
        final estimate = _estimate(t),
            downstream = path(child, Set.of(visiting));
        if (estimate == null || downstream == null) return memo[id] = null;
        final remaining = (estimate - (t.usedTime ?? 0))
            .clamp(0, estimate)
            .toDouble();
        if (remaining + downstream > longest) longest = remaining + downstream;
      }
      return memo[id] = longest;
    }

    final historicalEfficiency = efficiency.readNullable<double>('efficiency');
    final inputs = <CardoInput>[];
    // Cursor pagination is by task id; ranking within each returned page remains
    // score ordered. Graph metadata is still complete for correct critical paths.
    final pageQuery = db.select(db.tasks)
      ..where((t) => t.id.isBiggerThanValue(afterId))
      ..orderBy([(t) => OrderingTerm.asc(t.id)]);
    if (limit != null) pageQuery.limit(limit);
    final page = await pageQuery.get();
    for (final t in page) {
      final stats = statsById[t.id];
      final context = contextById[t.id];
      final estimate = _estimate(t);
      final resourceBlocked =
          context?.resourcesReady == false ||
          (context?.availableMinutes != null &&
              estimate != null &&
              (estimate - (t.usedTime ?? 0)).clamp(0, estimate) >
                  context!.availableMinutes!);
      inputs.add(
        CardoInput(
          id: t.id,
          priority: t.priority,
          status: t.status,
          deadline: t.ddl,
          createdAt: t.createdAt,
          estimatedMinutes: estimate?.toDouble(),
          usedTime: t.usedTime?.toDouble(),
          historicalEfficiency: historicalEfficiency,
          criticalPathMinutes: path(t.id, {}),
          blocked: blockedIds.contains(t.id),
          resourcesReady: resourceBlocked ? false : context?.resourcesReady,
          energyMatch: context?.energyMatch,
          goalImpact: context?.goalImpact,
          successes: stats?.read<int>('successes') ?? 0,
          attempts: stats?.read<int>('attempts') ?? 0,
          accepted: stats?.read<int>('accepted') ?? 0,
          feedbackCount: stats?.read<int>('feedback_count') ?? 0,
        ),
      );
    }
    return scoring.calculateBatch(inputs, now: instant);
  });

  /// All affected tasks (including downstream gates and upstream path benefits)
  /// recompute after a committed write, configuration replacement or clock tick.
  Stream<List<CardoResult>> watch({
    Duration interval = const Duration(minutes: 1),
  }) {
    late StreamController<List<CardoResult>> controller;
    StreamSubscription<dynamic>? subscription;
    Timer? timer;
    var pending = false, running = false, stopped = false;
    Future<void> refresh() async {
      pending = true;
      if (running || stopped) return;
      running = true;
      try {
        while (pending && !stopped) {
          pending = false;
          final results = await calculate();
          if (!stopped &&
              results.every(
                (r) => r.configRevision == scoring.configs.current.revision,
              )) {
            controller.add(results);
          } else if (!stopped) {
            pending = true;
          }
        }
      } catch (error, stack) {
        if (!stopped) controller.addError(error, stack);
      } finally {
        running = false;
      }
    }

    void changed() {
      unawaited(refresh());
    }

    controller = StreamController<List<CardoResult>>(
      onListen: () {
        scoring.configs.addListener(changed);
        subscription = db
            .customSelect(
              'SELECT 1',
              readsFrom: {
                db.tasks,
                db.taskDependencies,
                db.taskEvents,
                db.taskContexts,
              },
            )
            .watch()
            .listen((_) => changed(), onError: controller.addError);
        timer = Timer.periodic(interval, (_) => changed());
      },
      onCancel: () async {
        stopped = true;
        timer?.cancel();
        scoring.configs.removeListener(changed);
        await subscription?.cancel();
      },
    );
    return controller.stream;
  }
}
