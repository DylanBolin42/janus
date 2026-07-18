import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/pages/SettingPage/subSettingPage/focusSetting/focus_setting_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget createFocusSettingPage() {
  return const ProviderScope(child: MaterialApp(home: FocusSettingPage()));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('FocusSettingPage renders with title', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createFocusSettingPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('专注'), findsWidgets);
  });

  testWidgets('FocusSettingPage has back button', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createFocusSettingPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
  });

  testWidgets('FocusSettingPage shows default focus mode', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createFocusSettingPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('默认专注模式'), findsOneWidget);
  });

  testWidgets('FocusSettingPage shows behavior section', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createFocusSettingPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('自动DND'), findsOneWidget);
    expect(find.text('通知折叠'), findsOneWidget);
    expect(find.text('应用白名单'), findsOneWidget);
  });

  testWidgets('FocusSettingPage shows temp leave section', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createFocusSettingPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('单次暂离时长'), findsOneWidget);
    expect(find.text('单次专注最大暂离次数'), findsOneWidget);
  });

  testWidgets('FocusSettingPage shows scene section', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createFocusSettingPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('场景渲染引擎'), findsOneWidget);
    expect(find.text('场景渲染质量'), findsOneWidget);
  });

  testWidgets('FocusSettingPage renders without crashing', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createFocusSettingPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
  });
}
