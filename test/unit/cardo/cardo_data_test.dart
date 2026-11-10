import 'dart:async';
import 'dart:io';
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
      await service.addUsedTime(id, 20, idempotencyKey: 'sample-20');
      await service.addUsedTime(id, 15, idempotencyKey: 'sample-15');
      expect((await read(id)).usedTime, 35);
      await service.complete(id);
      await expectLater(service.complete(id), throwsStateError);
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
      await expectLater(
        service.addUsedTime(id, -1, idempotencyKey: 'sample--1'),
        throwsArgumentError,
      );
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
      await service.addUsedTime(a, 120, idempotencyKey: 'sample-120');
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
  for (final status in [-1, 0, 1, 2, 99]) {
    for (final operation in ['complete', 'reopen']) {
      final allowed = operation == 'complete'
          ? {0, 2}.contains(status)
          : status == 1;
      test(
        '$operation status $status: ${allowed ? 'allowed' : 'rejected'}',
        () async {
          final id = await create('transition');
          await (db.update(db.tasks)..where((t) => t.id.equals(id))).write(
            TasksCompanion(status: Value(status)),
          );
          final before = await db.select(db.taskEvents).get();
          final action = operation == 'complete'
              ? service.complete(id)
              : service.reopen(id);
          if (allowed) {
            await action;
            expect((await read(id)).status, operation == 'complete' ? 1 : 0);
          } else {
            await expectLater(action, throwsStateError);
            expect((await read(id)).status, status);
            expect(await db.select(db.taskEvents).get(), before);
          }
        },
      );
    }
  }
  test('DAO rejects every non-whitelisted changed status pair', () async {
    final allowed = <int, Set<int>>{
      0: {1, 2, -1},
      2: {0, 1, -1},
      -1: {0, 2},
      1: {0},
    };
    for (final from in [-1, 0, 1, 2, 99]) {
      for (final to in [-1, 0, 1, 2, 99]) {
        if (from == to || (allowed[from]?.contains(to) ?? false)) continue;
        final id = await create('invalid');
        await (db.update(db.tasks)..where((t) => t.id.equals(id))).write(
          TasksCompanion(status: Value(from)),
        );
        await expectLater(
          db.taskDao.editTask(id: id, status: Value(to)),
          throwsStateError,
        );
        expect((await read(id)).status, from);
      }
    }
  });
  test(
    'time observation retries are idempotent, including after completion',
    () async {
      final id = await create('time');
      await service.addUsedTime(id, 10, idempotencyKey: 'session');
      await service.addUsedTime(id, 10, idempotencyKey: 'session');
      await expectLater(
        service.addUsedTime(id, 11, idempotencyKey: 'session'),
        throwsStateError,
      );
      await expectLater(
        service.addUsedTime(id, 10, idempotencyKey: ''),
        throwsArgumentError,
      );
      expect((await read(id)).usedTime, 10);
      await service.complete(id);
      await service.addUsedTime(id, 10, idempotencyKey: 'session');
      await expectLater(
        service.addUsedTime(id, 5, idempotencyKey: 'new'),
        throwsStateError,
      );
      expect(
        (await service.eventPage(id)).where((e) => e.kind == 'time_logged'),
        hasLength(1),
      );
      expect((await read(id)).usedTime, 10);
    },
  );
  test(
    'concurrent retries accumulate once and distinct observations accumulate fully',
    () async {
      final id = await create('concurrent');
      await Future.wait(
        List.generate(
          20,
          (_) => service.addUsedTime(id, 7, idempotencyKey: 'same'),
        ),
      );
      expect((await read(id)).usedTime, 7);
      await Future.wait(
        List.generate(
          20,
          (i) => service.addUsedTime(id, 2, idempotencyKey: 'other-$i'),
        ),
      );
      expect((await read(id)).usedTime, 47);
      final first = await service.eventPage(id, limit: 10);
      final second = await service.eventPage(
        id,
        afterId: first.last.id,
        limit: 100,
      );
      expect({
        ...first.map((e) => e.id),
        ...second.map((e) => e.id),
      }, hasLength(21));
    },
  );
  test(
    'independent SQLite connections serialize concurrent keyed retries',
    () async {
      final dir = await Directory.systemTemp.createTemp('cardo-retry');
      final file = File('${dir.path}/retry.sqlite');
      AppDatabase open() => AppDatabase.forTesting(
        NativeDatabase.createInBackground(
          file,
          setup: (raw) => raw.execute('PRAGMA busy_timeout = 5000'),
        ),
      );
      final first = open();
      await first.customSelect('SELECT 1 FROM tasks').get();
      final second = open();
      addTearDown(() async {
        await first.close();
        await second.close();
        await dir.delete(recursive: true);
      });
      await second.customSelect('SELECT 1 FROM tasks').get();
      final id = await first
          .into(first.tasks)
          .insert(TasksCompanion.insert(title: 'shared', ddl: now));
      final a = CardoDataService(first, service.scoring),
          b = CardoDataService(second, service.scoring);
      await Future.wait(
        List.generate(
          10,
          (i) =>
              (i.isEven ? a : b).addUsedTime(id, 9, idempotencyKey: 'shared'),
        ),
      );
      await Future.wait([
        a.addUsedTime(id, 3, idempotencyKey: 'a'),
        b.addUsedTime(id, 4, idempotencyKey: 'b'),
      ]);
      expect((await first.taskDao.getAllTasks()).single.usedTime, 16);
      expect(await first.select(first.taskEvents).get(), hasLength(3));
    },
  );
  test(
    'scoring cursor pages preserve full-graph scores without duplicates',
    () async {
      final a = await create('a'), b = await create('b'), c = await create('c');
      await service.addDependency(a, c);
      final all = await service.calculate();
      final page = await service.calculate(afterId: a, limit: 1);
      expect(page.single.taskId, b);
      expect(page.single.score, all.firstWhere((r) => r.taskId == b).score);
      await expectLater(service.calculate(limit: 0), throwsArgumentError);
      expect(await service.calculate(afterId: c), isEmpty);
      final indexes = await db
          .customSelect("PRAGMA index_list('task_events')")
          .get();
      expect(
        indexes.map((r) => r.read<String>('name')),
        containsAll([
          'task_event_idempotency',
          'task_event_history',
          'task_event_kind',
        ]),
      );
    },
  );
  test('v4 upgrade preserves observations and adds retry key and indexes', () async {
    final migrated = AppDatabase.forTesting(
      NativeDatabase.memory(
        setup: (raw) {
          raw.execute(
            'CREATE TABLE tasks (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, description TEXT, ddl INTEGER NOT NULL, est_hour INTEGER, est_minute INTEGER, priority INTEGER NOT NULL DEFAULT 0, tags TEXT, status INTEGER NOT NULL DEFAULT 0, created_at INTEGER, started_at INTEGER, completed_at INTEGER, used_time INTEGER CHECK(used_time >= 0), priority_explicit INTEGER, dependency_graph_known INTEGER)',
          );
          raw.execute(
            'CREATE TABLE tags (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE)',
          );
          raw.execute(
            'CREATE TABLE task_dependencies (predecessor INTEGER NOT NULL REFERENCES tasks(id), successor INTEGER NOT NULL REFERENCES tasks(id), PRIMARY KEY(predecessor,successor))',
          );
          raw.execute(
            'CREATE TABLE task_contexts (task_id INTEGER NOT NULL PRIMARY KEY REFERENCES tasks(id), resources_ready INTEGER, available_minutes INTEGER, energy_match REAL, goal_impact REAL, expires_at INTEGER NOT NULL)',
          );
          raw.execute(
            'CREATE TABLE task_events (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, task_id INTEGER NOT NULL REFERENCES tasks(id), kind TEXT NOT NULL, occurred_at INTEGER NOT NULL, minutes INTEGER, estimated_minutes INTEGER, priority_value INTEGER, reason TEXT, config_revision INTEGER)',
          );
          raw.execute(
            "INSERT INTO tasks(id,title,ddl,used_time) VALUES(1,'existing',1794139200,15)",
          );
          raw.execute(
            "INSERT INTO task_events(task_id,kind,occurred_at,minutes) VALUES(1,'time_logged',1794139200,15)",
          );
          raw.execute('PRAGMA user_version = 4');
        },
      ),
    );
    addTearDown(migrated.close);
    expect((await migrated.taskDao.getAllTasks()).single.usedTime, 15);
    expect(
      (await migrated.select(migrated.taskEvents).get()).single.idempotencyKey,
      isNull,
    );
    final writer = CardoDataService(migrated, service.scoring);
    await writer.addUsedTime(1, 5, idempotencyKey: 'post-upgrade');
    await writer.addUsedTime(1, 5, idempotencyKey: 'post-upgrade');
    expect((await migrated.taskDao.getAllTasks()).single.usedTime, 20);
    expect(
      await migrated.customSelect('PRAGMA foreign_key_check').get(),
      isEmpty,
    );
  });
  for (final version in [1, 2, 3]) {
    test(
      'upgrade real v$version SQLite schema to v5 preserves unknown history',
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
