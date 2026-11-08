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
}
