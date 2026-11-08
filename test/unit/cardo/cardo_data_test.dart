import 'dart:async';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart' hide Table;
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/database/app_database.dart';
import 'package:janus/models/task.dart';
import 'package:janus/services/cardo/cardo_config.dart';
import 'package:janus/services/cardo/cardo_data_service.dart';
import 'package:janus/services/cardo/cardo_scoring_service.dart';

void main() {
  late AppDatabase db;
  late CardoDataService service;
  final now = DateTime.utc(2026, 11, 8, 12);
  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = CardoDataService(
      db,
      CardoScoringService(CardoConfigService()),
      clock: () => now,
    );
    addTearDown(db.close);
  });
  Future<int> create(String name) => db.taskDao.createTask(
    TaskDraft(
      title: name,
      ddl: now.add(const Duration(hours: 6)),
      priority: 3,
      est: const TimeOfDay(hour: 1, minute: 0),
    ),
  );
  Future<Task> read(int id) =>
      (db.select(db.tasks)..where((t) => t.id.equals(id))).getSingle();
  test(
    'creation start actual time completion and undo preserve evidence',
    () async {
      final id = await create('task');
      expect((await read(id)).createdAt, isNotNull);
      expect((await read(id)).usedTime, isNull);
      await service.start(id);
      await service.start(id);
      expect((await read(id)).startedAt?.toUtc(), now);
      await service.addUsedTime(id, 20);
      await service.addUsedTime(id, 15);
      expect((await read(id)).usedTime, 35);
      await service.complete(id);
      await service.complete(id);
      expect((await read(id)).completedAt?.toUtc(), now);
      expect(
        (await db.select(db.taskEvents).get()).where(
          (e) => e.kind == 'completed',
        ),
        hasLength(1),
      );
      await service.reopen(id);
      expect((await read(id)).completedAt, isNull);
      expect((await read(id)).usedTime, 35);
      expect(
        (await db.select(db.taskEvents).get()).where(
          (e) => e.kind == 'reopened',
        ),
        hasLength(1),
      );
      await expectLater(service.addUsedTime(id, -1), throwsArgumentError);
    },
  );
  test(
    'dependency cycle rejection, deletion, gates and critical path',
    () async {
      final a = await create('a'), b = await create('b'), c = await create('c');
      await service.addDependency(a, b);
      await service.addDependency(b, c);
      await expectLater(service.addDependency(c, a), throwsStateError);
      await expectLater(service.addDependency(a, a), throwsStateError);
      await expectLater(service.start(b), throwsStateError);
      service.scoring.configs.replaceJson(
        '{"version":2,"factors":{"dependency":{"enabled":true,"weight":1}}}',
      );
      var result = await service.calculate(now: now);
      expect(
        result.firstWhere((r) => r.taskId == a).factors['dependency'],
        closeTo(2 / 3, 1e-12),
      );
      expect(result.firstWhere((r) => r.taskId == b).eligibility, 'excluded');
      await service.complete(a);
      result = await service.calculate(now: now);
      expect(result.firstWhere((r) => r.taskId == b).eligibility, 'eligible');
      await service.removeDependency(b, c);
      expect(
        (await service.calculate())
            .firstWhere((r) => r.taskId == c)
            .eligibility,
        'eligible',
      );
    },
  );
  test(
    'committed dependencies and completion trigger downstream stream recalculation',
    () async {
      final a = await create('a'), b = await create('b');
      await service.addDependency(a, b);
      final snapshots = <List<CardoResult>>[];
      final ready = Completer<void>();
      final sub = service.watch().listen((r) {
        snapshots.add(r);
        if (r.firstWhere((x) => x.taskId == b).eligibility == 'eligible' &&
            !ready.isCompleted) {
          ready.complete();
        }
      });
      addTearDown(sub.cancel);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await service.complete(a);
      await ready.future.timeout(const Duration(seconds: 5));
      expect(
        snapshots.first.firstWhere((r) => r.taskId == b).eligibility,
        'excluded',
      );
    },
  );
  test(
    'context expires and actual feedback/outcomes are not inferred from status',
    () async {
      final id = await create('a');
      await service.fail(id, 'user attempt failed');
      await service.complete(id);
      await service.reopen(id);
      await service.feedback(id, 'accepted', configRevision: 0);
      await db.taskDao.editTask(id: id, priority: const Value(2));
      expect((await read(id)).priorityExplicit, isTrue);
      service.scoring.configs.replaceJson(
        '{"version":2,"factors":{"success":{"enabled":true,"weight":1},"feedback":{"enabled":true,"weight":1}}}',
      );
      var r = (await service.calculate()).single;
      expect(r.factors['success'], .5);
      expect(r.factors['feedback'], .5);
      await service.setContext(
        id,
        expiresAt: now.add(const Duration(hours: 1)),
        resourcesReady: false,
      );
      expect(
        (await service.calculate(now: now)).single.eligibility,
        'excluded',
      );
      r = (await service.calculate(
        now: now.add(const Duration(hours: 2)),
      )).single;
      expect(r.eligibility, 'eligible');
    },
  );
  test(
    'completion samples provide real historical efficiency to new tasks',
    () async {
      final a = await create('completed'), b = await create('new');
      await service.addUsedTime(a, 120);
      await service.complete(a);
      service.scoring.configs.replaceJson(
        '{"version":2,"factors":{"efficiency":{"enabled":true,"weight":1}}}',
      );
      final result = (await service.calculate()).firstWhere(
        (r) => r.taskId == b,
      );
      expect(result.factors['efficiency'], .5);
    },
  );
  test(
    'configuration publication triggers stream recalculation with current revision',
    () async {
      await create('a');
      final iterator = StreamIterator(service.watch());
      addTearDown(iterator.cancel);
      await iterator.moveNext();
      service.scoring.configs.replaceJson(
        '{"factors":{"urgency":{"normalization":{"half_life_hours":48}}}}',
      );
      do {
        await iterator.moveNext().timeout(const Duration(seconds: 5));
      } while (iterator.current.single.configRevision !=
          service.scoring.configs.current.revision);
      expect(iterator.current.single.score, closeTo(95.83333333333333, 1e-10));
    },
  );
  test(
    'legacy unknown graph deweights dependency until explicitly confirmed',
    () async {
      final id = await db
          .into(db.tasks)
          .insert(
            TasksCompanion.insert(
              title: 'legacy',
              ddl: now,
              priority: const Value(3),
            ),
          );
      service.scoring.configs.replaceJson(
        '{"version":2,"factors":{"dependency":{"enabled":true,"weight":1}}}',
      );
      var r = (await service.calculate()).single;
      expect(r.score, 100);
      expect(r.warnings, contains('missing_data:dependency:weight_removed'));
      await service.confirmDependencyGraph(id);
      r = (await service.calculate()).single;
      expect(r.factors['dependency'], 0);
      expect(r.score, 50);
    },
  );
  for (final version in [1, 2, 3]) {
    test(
      'upgrade real v$version SQLite schema to v4 preserves unknown history',
      () async {
        final executor = NativeDatabase.memory(
          setup: (raw) {
            raw.execute(
              'CREATE TABLE tasks (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, description TEXT, ddl INTEGER NOT NULL, est_hour INTEGER, est_minute INTEGER, priority INTEGER NOT NULL DEFAULT 0, tags TEXT${version >= 3 ? ', status INTEGER NOT NULL DEFAULT 0' : ''})',
            );
            if (version >= 2) {
              raw.execute(
                'CREATE TABLE tags (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE)',
              );
            }
            raw.execute(
              "INSERT INTO tasks(title,ddl,est_hour,est_minute) VALUES ('legacy', 1794139200, 1, 30)",
            );
            raw.execute('PRAGMA user_version = $version');
          },
        );
        final migrated = AppDatabase.forTesting(executor);
        addTearDown(migrated.close);
        final t = (await migrated.taskDao.getAllTasks()).single;
        expect(t.title, 'legacy');
        expect(t.estHour, 1);
        expect(t.estMinute, 30);
        expect(t.createdAt, isNull);
        expect(t.startedAt, isNull);
        expect(t.completedAt, isNull);
        expect(t.usedTime, isNull);
        expect(t.priorityExplicit, isNull);
        expect(t.status, 0);
        expect(await migrated.select(migrated.taskEvents).get(), isEmpty);
        expect(await migrated.select(migrated.taskDependencies).get(), isEmpty);
        expect(
          await migrated.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );
      },
    );
  }
}
