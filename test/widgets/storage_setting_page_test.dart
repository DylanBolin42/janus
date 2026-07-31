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

  testWidgets('StorageSettingPage tapping "删除数据库" displays confirmation dialog', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createStorageSettingPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Tap "删除数据库"
    await tester.tap(find.text('删除数据库'));
    await tester.pumpAndSettle();

    // Dialog should be present
    expect(find.text('确认删除数据库？'), findsOneWidget);
    expect(find.text('此操作将永久清空本地所有数据，且不可逆。请谨慎操作。'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
    expect(find.text('确认删除'), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    // Dialog should be dismissed
    expect(find.text('确认删除数据库？'), findsNothing);

    // Tap "删除数据库" again
    await tester.tap(find.text('删除数据库'));
    await tester.pumpAndSettle();

    // Tap Confirm Delete
    await tester.tap(find.text('确认删除'));
    await tester.pumpAndSettle();

    // Dialog should be dismissed and snackbar shown
    expect(find.text('确认删除数据库？'), findsNothing);
    expect(find.text('数据库已成功删除'), findsOneWidget);
  });
}
