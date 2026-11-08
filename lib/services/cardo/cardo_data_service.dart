import 'dart:async';
import 'package:drift/drift.dart';
import '../../database/app_database.dart';
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
    if (task.status == 1 || task.status == -1) {
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
  /// until the first observation. Each call is a new observation, not a timer.
  Future<void> addUsedTime(int id, int minutes) => db.transaction(() async {
    if (minutes <= 0) {
      throw ArgumentError.value(minutes, 'minutes', 'must be positive');
    }
    final task = await _task(id);
    if (task.status == 1 || task.status == -1) {
      throw StateError('Task is not active');
    }
    await (db.update(db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(usedTime: Value((task.usedTime ?? 0) + minutes)),
    );
    await db
        .into(db.taskEvents)
        .insert(
          TaskEventsCompanion.insert(
            taskId: id,
            kind: 'time_logged',
            occurredAt: clock().toUtc(),
            minutes: Value(minutes),
            estimatedMinutes: Value(_estimate(task)),
          ),
        );
  });

  Future<void> complete(int id) => db.transaction(() async {
    final task = await _task(id);
    if (task.status == 1) {
      return; // Retry cannot duplicate a successful attempt.
    }
    if (await _blocked(id)) throw StateError('Unfinished prerequisite');
    await db.taskDao.editTask(
      id: id,
      status: const Value(1),
      occurredAt: clock(),
    );
  });
  Future<void> reopen(int id) =>
      db.taskDao.editTask(id: id, status: const Value(0), occurredAt: clock());
  Future<void> fail(int id, String reason) => db.transaction(() async {
    final task = await _task(id);
    if (task.status == 1 || task.status == -1) {
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
      });
  Future<List<TaskDependency>> getDependencies() =>
      db.select(db.taskDependencies).get();

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
  }) => db.transaction(() async {
    final instant = (now ?? clock()).toUtc();
    final tasks = await db.select(db.tasks).get();
    final edges = await db.select(db.taskDependencies).get();
    final events = await db.select(db.taskEvents).get();
    final contexts = await db.select(db.taskContexts).get();
    final byId = {for (final t in tasks) t.id: t};
    final children = <int, List<int>>{};
    for (final e in edges) {
      (children[e.predecessor] ??= []).add(e.successor);
    }
    final memo = <int, double?>{};
    double? path(int id, Set<int> visiting) {
      if (memo.containsKey(id)) return memo[id];
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

    final completedSamples = events
        .where(
          (e) =>
              e.kind == 'completed' &&
              e.minutes != null &&
              e.minutes! > 0 &&
              e.estimatedMinutes != null &&
              e.estimatedMinutes! > 0,
        )
        .toList();
    final historicalEfficiency = completedSamples.isEmpty
        ? null
        : completedSamples
                  .map(
                    (e) => (e.estimatedMinutes! / e.minutes!).clamp(0.0, 1.0),
                  )
                  .reduce((a, b) => a + b) /
              completedSamples.length;
    final inputs = <CardoInput>[];
    for (final t in tasks) {
      final history = events.where((e) => e.taskId == t.id).toList();
      final successes = history.where((e) => e.kind == 'completed').length;
      final attempts =
          successes + history.where((e) => e.kind == 'failed').length;
      final feedback = history
          .where(
            (e) => ['accepted', 'ignored', 'priority_changed'].contains(e.kind),
          )
          .toList();
      final context = contexts
          .where((c) => c.taskId == t.id && c.expiresAt.isAfter(instant))
          .firstOrNull;
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
          blocked: edges.any(
            (e) => e.successor == t.id && byId[e.predecessor]?.status != 1,
          ),
          resourcesReady: resourceBlocked ? false : context?.resourcesReady,
          energyMatch: context?.energyMatch,
          goalImpact: context?.goalImpact,
          successes: successes,
          attempts: attempts,
          accepted: feedback.where((e) => e.kind == 'accepted').length,
          feedbackCount: feedback.length,
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
