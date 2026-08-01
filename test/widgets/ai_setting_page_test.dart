import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/pages/SettingPage/subSettingPage/aiSetting/ai_setting_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

Widget createAiSettingPage() {
  return const ProviderScope(child: MaterialApp(home: AiSettingPage()));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('AiSettingPage renders with title', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createAiSettingPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('AI'), findsWidgets);
  });

  testWidgets('AiSettingPage has back button', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createAiSettingPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
  });

  testWidgets('AiSettingPage shows description section', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createAiSettingPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('说明'), findsOneWidget);
    expect(find.textContaining('AI设置内的设置项如启用能够增进用户体验'), findsOneWidget);
  });

  testWidgets('AiSettingPage shows config section', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createAiSettingPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Endpoint'), findsOneWidget);
    expect(find.text('API Key'), findsOneWidget);
    expect(find.text('Model'), findsOneWidget);
  });

  testWidgets('AiSettingPage shows AI features section', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createAiSettingPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('每日日报总结'), findsOneWidget);
    expect(find.text('更完善的分析报告'), findsOneWidget);
    expect(find.text('智慧文本日程提取'), findsOneWidget);
    expect(find.text('图片日程提取'), findsOneWidget);
  });

  testWidgets('AiSettingPage renders without crashing', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createAiSettingPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
  });

  testWidgets('AiSettingPage validates endpoint input and enforces HTTPS', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createAiSettingPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Find the Endpoint text field (it's the first GlassTextField in the config section)
    final endpointFinder = find.byType(GlassTextField);
    expect(endpointFinder, findsWidgets);

    // 1. Enter an insecure remote URL and verify that an error message is shown
    await tester.enterText(endpointFinder.first, 'http://api.example.com');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('为了安全，远程端点必须使用 HTTPS 协议'), findsOneWidget);

    // 2. Enter a secure HTTPS URL and verify that the error message goes away
    await tester.enterText(endpointFinder.first, 'https://api.secure-ai.com');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('为了安全，远程端点必须使用 HTTPS 协议'), findsNothing);

    // 3. Enter a local HTTP URL (localhost) and verify it is allowed without errors
    await tester.enterText(endpointFinder.first, 'http://localhost:11434');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('为了安全，远程端点必须使用 HTTPS 协议'), findsNothing);
  });
}
