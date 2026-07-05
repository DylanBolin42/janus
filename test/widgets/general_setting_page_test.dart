import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/pages/SettingPage/subSettingPage/generalSetting/general_setting_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    // Mock SharedPreferences to avoid platform channel errors
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('GeneralSettingPage renders with title', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: GeneralSettingPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('通用'), findsWidgets);
  });

  testWidgets('GeneralSettingPage has back button', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: GeneralSettingPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
  });

  testWidgets('GeneralSettingPage shows appearance tiles', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: GeneralSettingPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('主题色'), findsOneWidget);
    expect(find.text('显示模式'), findsOneWidget);
    expect(find.text('液态玻璃渲染强度'), findsOneWidget);
  });

  testWidgets('GeneralSettingPage shows language section', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: GeneralSettingPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('语言'), findsWidgets);
  });

  testWidgets('GeneralSettingPage shows naming style section', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: GeneralSettingPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('命名风格'), findsOneWidget);
    expect(find.text('Tab命名风格'), findsOneWidget);
  });

  testWidgets('GeneralSettingPage shows permissions tiles', (tester) async {
    // Use a larger surface size so all content is visible without scrolling
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: GeneralSettingPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('电池优化'), findsOneWidget);
    expect(find.text('自启动'), findsOneWidget);
    expect(find.text('无障碍服务'), findsOneWidget);
  });
}
