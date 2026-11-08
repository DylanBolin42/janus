import 'dart:async';
import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/database/app_database.dart';
import 'package:janus/models/app_settings.dart';
import 'package:janus/models/task.dart';
import 'package:janus/services/settings_service.dart';
import 'package:janus/services/sync/sync_backend.dart';
import 'package:janus/services/sync/sync_credentials.dart';
import 'package:janus/services/sync/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeBackend implements SyncBackend {
  bool fail = false;
  int uploads = 0;
  String? snapshot;
  Completer<void>? gate;
  @override
  Future<void> verify() async {
    if (gate != null) await gate!.future;
    if (fail) throw const SyncFailure('认证失败');
  }

  @override
  Future<void> upload(String value) async {
    uploads++;
    snapshot = value;
  }

  @override
  Future<String> download() async => snapshot!;
}

class FailingSettings extends SettingsService {
  bool fail = true;
  @override
  Future<void> save(AppSettings settings) async {
    if (fail) {
      fail = false;
      throw StateError('disk');
    }
    return super.save(settings);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const config = SyncConfig(
    'https://example.com/dav',
    'user',
    'secret',
    'janus.json',
  );
  late AppDatabase db;
  late SettingsService settings;
  late SnapshotStore store;
  late FakeBackend backend;
  late SyncService sync;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    settings = SettingsService();
    store = SnapshotStore(db, settings);
    backend = FakeBackend();
    sync = SyncService(backend: (_) => backend, store: () => store);
  });
  tearDown(() async {
    sync.dispose();
    await db.close();
  });

  Future<void> seed() async {
    await db.taskDao.createTag('工作');
    await db.taskDao.createTask(
      TaskDraft(
        title: '测试任务',
        ddl: DateTime(2026),
        status: 1,
        est: const TimeOfDay(hour: 1, minute: 15),
        tags: ['工作'],
      ),
    );
  }

  test(
    'failure does not create success time; retry persists only real completion',
    () async {
      backend.fail = true;
      final phases = <SyncPhase>[];
      sync.addListener(() => phases.add(sync.phase));
      await sync.run(SyncAction.upload, config);
      expect(sync.phase, SyncPhase.failed);
      expect(sync.lastSync, isNull);
      expect(backend.uploads, 0);
      backend.fail = false;
      await sync.run(sync.lastAction!, config);
      expect(phases, [
        SyncPhase.connecting,
        SyncPhase.failed,
        SyncPhase.connecting,
        SyncPhase.syncing,
        SyncPhase.success,
      ]);
      expect(backend.uploads, 1);
      final reloaded = SyncService(backend: (_) => backend, store: () => store);
      await reloaded.refresh();
      expect(reloaded.lastSync, sync.lastSync);
      reloaded.dispose();
    },
  );

  test('check never updates last synchronization timestamp', () async {
    await sync.run(SyncAction.check, config);
    expect(sync.message, contains('尚未传输'));
    expect(sync.lastSync, isNull);
    expect(backend.uploads, 0);
  });

  test('overlapping requests are ignored', () async {
    backend.gate = Completer<void>();
    final running = sync.run(SyncAction.upload, config);
    await sync.run(SyncAction.upload, config);
    backend.gate!.complete();
    await running;
    expect(backend.uploads, 1);
  });

  test(
    'snapshot round trip restores tasks, tags and settings but keeps device security settings',
    () async {
      await seed();
      await settings.save(
        const AppSettings(
          themeMode: AppThemeMode.dark,
          syncEnabled: true,
          endPoint: 'private-endpoint',
        ),
      );
      final raw = await store.export();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      expect(json['version'], 1);
      expect(json['settings'], isNot(contains('syncEnabled')));
      expect(raw, isNot(contains('private-endpoint')));
      await db.taskDao.deleteAllData();
      await settings.save(
        const AppSettings(syncEnabled: false, endPoint: 'local'),
      );
      backend.snapshot = raw;
      await sync.run(SyncAction.download, config);
      expect(sync.phase, SyncPhase.success);
      final tasks = await db.taskDao.getAllTasks();
      expect(tasks.single.title, '测试任务');
      expect(tasks.single.status, 1);
      expect(tasks.single.estMinute, 15);
      expect(tasks.single.tags, ['工作']);
      expect((await db.taskDao.getAllTags()).single.name, '工作');
      final restored = await settings.load();
      expect(restored.themeMode, AppThemeMode.dark);
      expect(restored.syncEnabled, false);
      expect(restored.endPoint, 'local');
    },
  );

  test('bad snapshots and duplicate IDs never delete local data', () async {
    await seed();
    final valid = jsonDecode(await store.export()) as Map<String, dynamic>;
    for (final raw in [
      'broken',
      jsonEncode({...valid, 'version': 2}),
      jsonEncode({
        ...valid,
        'tasks': [valid['tasks'][0], valid['tasks'][0]],
      }),
      jsonEncode({
        ...valid,
        'tasks': [
          {...valid['tasks'][0] as Map, 'title': ''},
        ],
      }),
      jsonEncode({
        ...valid,
        'settings': {'themeMode': 99},
      }),
    ]) {
      backend.snapshot = raw;
      await sync.run(SyncAction.download, config);
      expect(sync.phase, SyncPhase.failed);
      expect(sync.lastSync, isNull);
      expect((await db.taskDao.getAllTasks()).single.title, '测试任务');
    }
  });

  test(
    'settings persistence failure rolls back task and tag replacements',
    () async {
      await seed();
      final raw = await store.export();
      await db.taskDao.deleteAllData();
      final failingStore = SnapshotStore(db, FailingSettings());
      await expectLater(failingStore.restore(raw), throwsA(isA<SyncFailure>()));
      expect(await db.taskDao.getAllTasks(), isEmpty);
      expect(await db.taskDao.getAllTags(), isEmpty);
    },
  );

  test('HTTPS and safe relative snapshot filenames required', () {
    for (final bad in [
      const SyncConfig('http://example.com', 'u', 'p', 'x.json'),
      const SyncConfig('https://u:p@example.com', 'u', 'p', 'x.json'),
      const SyncConfig('https://example.com', 'u', 'p', '../x.json'),
      const SyncConfig('https://example.com?key=secret', 'u', 'p', 'x.json'),
      const SyncConfig('https://example.com', '', '', 'x.json'),
    ]) {
      expect(() => bad.directory, throwsA(isA<SyncFailure>()));
    }
  });

  test(
    'credentials use native secure channel and never shared preferences',
    () async {
      String? secureValue;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SyncCredentials.channel, (call) async {
            if (call.method == 'write') secureValue = call.arguments as String;
            return call.method == 'read' ? secureValue : null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SyncCredentials.channel, null),
      );
      final credentials = SyncCredentials();
      expect(await credentials.load(), isNull);
      await credentials.save(config);
      expect((await credentials.load())!.password, 'secret');
      expect((await SharedPreferences.getInstance()).getKeys(), isEmpty);
    },
  );

  test('platform storage failure does not fall back to plaintext', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SyncCredentials.channel, (_) async {
          throw PlatformException(code: 'locked');
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SyncCredentials.channel, null),
    );
    await expectLater(
      SyncCredentials().save(config),
      throwsA(isA<PlatformException>()),
    );
    expect((await SharedPreferences.getInstance()).getKeys(), isEmpty);
  });
}
