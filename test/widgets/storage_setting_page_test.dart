import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/pages/SettingPage/subSettingPage/storageSetting/storage_setting_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget createStorageSettingPage() {
  return const ProviderScope(child: MaterialApp(home: StorageSettingPage()));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

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

  testWidgets('Tapping delete database button shows GlassDialog, cancel works', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createStorageSettingPage());
    await tester.pumpAndSettle();

    // Tap "删除数据库"
    final deleteButton = find.text('删除数据库');
    expect(deleteButton, findsOneWidget);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    // Verify GlassDialog is shown with expected content
    expect(find.text('确定要删除数据库吗？'), findsOneWidget);
    expect(find.text('此操作将永久清空本地所有日程、任务和配置数据，且无法撤销。'), findsOneWidget);

    // Tap Cancel button
    final cancelButton = find.text('取消');
    expect(cancelButton, findsOneWidget);
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();

    // Verify dialog is dismissed
    expect(find.text('确定要删除数据库吗？'), findsNothing);
  });

  testWidgets('Tapping delete database button shows GlassDialog, confirm works and shows toast', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createStorageSettingPage());
    await tester.pumpAndSettle();

    // Tap "删除数据库"
    final deleteButton = find.text('删除数据库');
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    // Verify GlassDialog is shown
    expect(find.text('确定要删除数据库吗？'), findsOneWidget);

    // Tap Confirm button
    final confirmButton = find.text('确认删除');
    expect(confirmButton, findsOneWidget);
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    // Verify dialog is dismissed
    expect(find.text('确定要删除数据库吗？'), findsNothing);

    // Verify toast is shown with success message
    expect(find.text('数据库已清空'), findsOneWidget);
  });
}
