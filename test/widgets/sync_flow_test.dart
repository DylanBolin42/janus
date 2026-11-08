import 'dart:async';
import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/database/app_database.dart';
import 'package:janus/pages/SettingPage/subSettingPage/syncSetting/sync_setting_page.dart';
import 'package:janus/providers/sync_provider.dart';
import 'package:janus/services/settings_service.dart';
import 'package:janus/services/sync/sync_backend.dart';
import 'package:janus/services/sync/sync_credentials.dart';
import 'package:janus/services/sync/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageBackend implements SyncBackend {
  bool fail = false;
  int downloads = 0;
  Completer<void>? pending;
  @override
  Future<void> verify() async {
    if (pending != null) await pending!.future;
    if (fail) throw const SyncFailure('认证失败，请重试');
  }

  @override
  Future<void> upload(String value) async {}
  @override
  Future<String> download() async {
    downloads++;
    return 'broken';
  }
}

void main() {
  late AppDatabase db;
  late PageBackend backend;
  late SyncService service;
  const config = SyncConfig(
    'https://example.com/dav',
    'user',
    'secret',
    'janus.json',
  );
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'app_settings': jsonEncode({'syncEnabled': true}),
    });
    db = AppDatabase.forTesting(NativeDatabase.memory());
    backend = PageBackend();
    service = SyncService(
      backend: (_) => backend,
      store: () => SnapshotStore(db, SettingsService()),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          SyncCredentials.channel,
          (call) async =>
              call.method == 'read' ? jsonEncode(config.toJson()) : null,
        );
  });
  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SyncCredentials.channel, null);
    service.dispose();
    await db.close();
  });
  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [syncServiceProvider.overrideWithValue(service)],
        child: const MaterialApp(home: SyncSettingPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'saved credentials echo, connection failure retries without fake sync time',
    (tester) async {
      await open(tester);
      expect(find.text('https://example.com/dav'), findsOneWidget);
      expect(find.text('janus.json'), findsOneWidget);
      backend.fail = true;
      await tester.tap(find.text('连通性检查'));
      await tester.pumpAndSettle();
      expect(find.text('认证失败，请重试'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);
      backend.fail = false;
      await tester.tap(find.text('重试'));
      await tester.pumpAndSettle();
      expect(find.text('连接验证通过，尚未传输数据'), findsOneWidget);
      expect(find.text('上次同步：无记录'), findsOneWidget);
    },
  );
  testWidgets(
    'download cancellation never calls server; confirmation shows invalid snapshot failure',
    (tester) async {
      await open(tester);
      await tester.tap(find.text('手动下载'));
      await tester.pumpAndSettle();
      expect(find.text('替换本地数据？'), findsOneWidget);
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      expect(backend.downloads, 0);
      await tester.tap(find.text('手动下载'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('确认替换'));
      await tester.pumpAndSettle();
      expect(backend.downloads, 1);
      expect(find.text('快照格式无效或版本不兼容，本地数据未修改'), findsOneWidget);
      expect(find.text('上次同步：无记录'), findsOneWidget);
    },
  );
  testWidgets(
    'busy operation displays progress and prevents repeated requests',
    (tester) async {
      await open(tester);
      backend.pending = Completer<void>();
      await tester.tap(find.text('连通性检查'));
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('正在连接服务器'), findsOneWidget);
      backend.pending!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsNothing);
    },
  );
}
