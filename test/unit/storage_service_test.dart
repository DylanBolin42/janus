import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/database/app_database.dart';
import 'package:janus/services/storage_service.dart';

void main() {
  late AppDatabase db;
  late StorageService service;
  late Directory directory;
  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    directory = await Directory.systemTemp.createTemp('janus_storage');
    service = StorageService(db, documents: () async => directory);
    await db.taskDao.seedSampleData();
  });
  tearDown(() async {
    await db.close();
    await directory.delete(recursive: true);
  });

  test('snapshot round trip restores all fields, IDs and counts', () async {
    final original = (await db.taskDao.getAllTasks())
        .map((t) => t.toJson())
        .toList();
    final file = await service.exportSnapshot();
    expect(await service.snapshots(), hasLength(1));
    final snapshot = await service.readSnapshot(file);
    await service.clear();
    expect((await service.statistics()).tasks, 0);
    await service.restore(snapshot);
    expect(
      (await db.taskDao.getAllTasks()).map((t) => t.toJson()).toList(),
      original,
    );
    final counts = await service.statistics();
    expect(counts.tasks, 6);
    expect(counts.tags, 5);
    expect(counts.completed, 1);
    expect(counts.bytes, isNull); // An in-memory DB has no file size.
    await db.taskDao.createTag('仍可写入');
  });

  test(
    'corrupt, missing fields and incompatible versions preserve data',
    () async {
      final file = await service.exportSnapshot();
      final valid =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final original = (await db.taskDao.getAllTasks())
          .map((t) => t.toJson())
          .toList();
      for (final source in [
        '{broken',
        jsonEncode({...valid, 'formatVersion': 999}),
        jsonEncode({...valid, 'schemaVersion': 999}),
        jsonEncode({...valid}..remove('tasks')),
        jsonEncode({
          ...valid,
          'tasks': [
            {'id': 1},
          ],
        }),
        jsonEncode({
          ...valid,
          'tags': [
            {'id': 1, 'name': 42},
          ],
        }),
      ]) {
        await file.writeAsString(source);
        await expectLater(service.readSnapshot(file), throwsFormatException);
        expect(
          (await db.taskDao.getAllTasks()).map((t) => t.toJson()).toList(),
          original,
        );
      }
    },
  );

  test(
    'failure after deletes and partial inserts rolls back everything',
    () async {
      final snapshot = await service.readSnapshot(
        await service.exportSnapshot(),
      );
      final original = (await db.taskDao.getAllTasks())
          .map((t) => t.toJson())
          .toList();
      final tags = await db.taskDao.getAllTags();
      // Fail only after several records have already been inserted.
      await db.customStatement('''
      CREATE TRIGGER fail_restore BEFORE INSERT ON tasks
      WHEN NEW.id = 3 BEGIN SELECT RAISE(ABORT, 'injected failure'); END
    ''');
      await expectLater(service.restore(snapshot), throwsA(anything));
      expect(
        (await db.taskDao.getAllTasks()).map((t) => t.toJson()).toList(),
        original,
      );
      expect(await db.taskDao.getAllTags(), tags);
    },
  );

  test('unreadable snapshot reports file error without mutation', () async {
    await expectLater(
      service.readSnapshot(File('${directory.path}/missing.json')),
      throwsA(isA<FileSystemException>()),
    );
    expect((await service.statistics()).tasks, 6);
  });
  test('reports actual SQLite file bytes including journal sidecars', () async {
    final file = File('${directory.path}/actual.sqlite');
    final diskDb = AppDatabase.forTesting(NativeDatabase(file));
    try {
      await diskDb.taskDao.seedSampleData();
      final stats = await StorageService(diskDb).statistics();
      var expected = await file.length();
      for (final suffix in ['-wal', '-shm']) {
        final sidecar = File('${file.path}$suffix');
        if (await sidecar.exists()) expected += await sidecar.length();
      }
      expect(stats.bytes, expected);
      expect(stats.bytes, greaterThan(0));
    } finally {
      await diskDb.close();
    }
  });

  test('export file failure leaves database untouched', () async {
    final blocker = File('${directory.path}/not_a_directory');
    await blocker.writeAsString('blocked');
    final unavailable = StorageService(
      db,
      documents: () async => Directory(blocker.path),
    );
    await expectLater(
      unavailable.exportSnapshot(),
      throwsA(isA<FileSystemException>()),
    );
    expect((await service.statistics()).tasks, 6);
  });
  test(
    'createdAt normalizes offsets to UTC and rejects timestamps without a zone',
    () {
      Map<String, dynamic> payload(String date) => {
        'formatVersion': 1,
        'schemaVersion': 3,
        'createdAt': date,
        'tasks': [],
        'tags': [],
      };
      for (final date in [
        '2026-11-08T03:00:00Z',
        '2026-11-08T11:00:00+08:00',
        '2026-11-07T21:30:00-05:30',
      ]) {
        final snapshot = StorageSnapshot.parse(jsonEncode(payload(date)), 3);
        expect(snapshot.createdAt, DateTime.utc(2026, 11, 8, 3));
        expect(snapshot.createdAt.isUtc, isTrue);
      }
      expect(
        () => StorageSnapshot.parse(
          jsonEncode(payload('2026-11-08T03:00:00')),
          3,
        ),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('时区'),
          ),
        ),
      );
    },
  );

  test(
    'simultaneous exports with identical timestamps have unique names and retain at most ten',
    () async {
      final fixed = StorageService(
        db,
        documents: () async => directory,
        now: () => DateTime.utc(2026),
      );
      final outputs = await Future.wait(
        List.generate(12, (_) => fixed.exportSnapshot()),
      );
      expect(outputs.map((f) => f.path).toSet(), hasLength(12));
      expect(await fixed.snapshots(), hasLength(StorageService.maxSnapshots));
      expect(await outputs.last.exists(), isTrue);
      expect(
        await (await fixed.snapshotDirectory())
            .list()
            .where((f) => f.path.endsWith('.tmp'))
            .toList(),
        isEmpty,
      );
    },
  );

  test(
    'retention deletes oldest owned snapshots to satisfy total bytes, keeps unrelated files',
    () async {
      final dir = await service.snapshotDirectory();
      final oldest = File('${dir.path}/janus_1.json');
      final newer = File('${dir.path}/janus_2.json');
      for (final file in [oldest, newer]) {
        final handle = await file.open(mode: FileMode.write);
        await handle.truncate(60 * 1024 * 1024);
        await handle.close();
      }
      await oldest.setLastModified(DateTime.utc(2020));
      await newer.setLastModified(DateTime.utc(2021));
      final external = File('${dir.path}/external.json');
      await external.writeAsString('external');
      final fresh = await service.exportSnapshot();
      expect(await oldest.exists(), isFalse);
      expect(await newer.exists(), isTrue);
      expect(await external.exists(), isTrue);
      expect(await fresh.exists(), isTrue);
      final owned = (await service.snapshots()).where(
        (f) => f.path.contains('/janus_'),
      );
      var total = 0;
      for (final file in owned) {
        total += await file.length();
      }
      expect(total, lessThanOrEqualTo(StorageService.maxSnapshotTotalBytes));
    },
  );

  test(
    'separate service instances serialize export, clear and restore',
    () async {
      final snapshot = await service.readSnapshot(
        await service.exportSnapshot(),
      );
      final entered = Completer<void>();
      final gate = Completer<void>();
      final slow = StorageService(
        db,
        documents: () async {
          if (!entered.isCompleted) entered.complete();
          await gate.future;
          return directory;
        },
      );
      final first = slow.exportForTransfer();
      await entered.future;
      var cleared = false;
      final clear = service.clear().then((_) {
        cleared = true;
      });
      final restore = service.restore(snapshot);
      final second = service.exportForTransfer();
      await Future<void>.delayed(Duration.zero);
      expect(cleared, isFalse);
      gate.complete();
      final firstData =
          jsonDecode(utf8.decode((await first).bytes)) as Map<String, dynamic>;
      await clear;
      await restore;
      final secondData =
          jsonDecode(utf8.decode((await second).bytes)) as Map<String, dynamic>;
      expect(firstData['tasks'], hasLength(6));
      expect(secondData['tasks'], hasLength(6));
      expect((await service.statistics()).tasks, 6);
    },
  );
}
