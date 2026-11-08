import 'dart:convert';
import 'dart:typed_data';
import 'package:janus/services/storage_file_picker.dart';
import 'package:drift/native.dart';
import 'package:janus/database/app_database.dart';
import 'package:janus/providers/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/pages/SettingPage/subSettingPage/storageSetting/storage_setting_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

late AppDatabase database;

class MemoryPicker implements StorageFilePicker {
  bool cancelled = false;
  @override
  Future<SnapshotSource?> pickJson() async => cancelled
      ? null
      : SnapshotSource(
          size: null,
          open: () => Stream.value(
            utf8.encode(
              jsonEncode({
                'formatVersion': 1,
                'schemaVersion': 3,
                'createdAt': '2026-11-08T00:00:00Z',
                'tasks': [],
                'tags': [],
              }),
            ),
          ),
          release: () async {},
        );
  @override
  Future<String?> saveJson(String name, Uint8List bytes) async => null;
}

Widget createStorageSettingPage({StorageFilePicker? picker}) {
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(database)],
    child: MaterialApp(home: StorageSettingPage(filePicker: picker)),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async => database.close());

  testWidgets('StorageSettingPage renders with title', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createStorageSettingPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('存储'), findsWidgets);
  });

  testWidgets('StorageSettingPage has back button', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createStorageSettingPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
  });

  testWidgets('StorageSettingPage shows storage info', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createStorageSettingPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('当前存储占用'), findsOneWidget);
  });

  testWidgets('StorageSettingPage shows database section', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createStorageSettingPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('导入数据库'), findsOneWidget);
    expect(find.text('导出数据库'), findsOneWidget);
    expect(find.text('删除数据库'), findsOneWidget);
  });

  testWidgets('StorageSettingPage shows log section', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createStorageSettingPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('本地模型训练'), findsOneWidget);
  });

  testWidgets('StorageSettingPage renders without crashing', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createStorageSettingPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'clear cancellation preserves data and confirmation refreshes counts',
    (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await database.taskDao.seedSampleData();
      await tester.pumpWidget(createStorageSettingPage());
      await tester.pumpAndSettle();
      expect(find.textContaining('任务：6，标签：5，已完成：1'), findsOneWidget);
      await tester.tap(find.text('删除数据库'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      expect(await database.taskDao.getAllTasks(), hasLength(6));
      await tester.tap(find.text('删除数据库'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('删除'));
      await tester.pumpAndSettle();
      expect(find.textContaining('任务：0，标签：0，已完成：0'), findsOneWidget);
      expect(await database.taskDao.getAllTasks(), isEmpty);
    },
  );
  testWidgets(
    'external import cancellation and confirmation protect existing data',
    (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await database.taskDao.seedSampleData();
      final picker = MemoryPicker()..cancelled = true;
      await tester.pumpWidget(createStorageSettingPage(picker: picker));
      await tester.pumpAndSettle();
      expect(find.text('应用内快照'), findsOneWidget);
      await tester.tap(find.text('导入数据库'));
      await tester.pumpAndSettle();
      expect(find.text('已取消选择文件，现有数据未修改'), findsOneWidget);
      expect(await database.taskDao.getAllTasks(), hasLength(6));
      picker.cancelled = false;
      await tester.tap(find.text('导入数据库'));
      await tester.pumpAndSettle();
      expect(find.text('替换全部任务和标签？'), findsOneWidget);
      expect(await database.taskDao.getAllTasks(), hasLength(6));
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      expect(await database.taskDao.getAllTasks(), hasLength(6));
      await tester.tap(find.text('导入数据库'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('确认导入'));
      await tester.pumpAndSettle();
      expect(await database.taskDao.getAllTasks(), isEmpty);
      expect(find.textContaining('任务：0，标签：0，已完成：0'), findsOneWidget);
      expect(find.text('快照已导入'), findsOneWidget);
    },
  );
}
