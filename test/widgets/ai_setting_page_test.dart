import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/pages/SettingPage/subSettingPage/aiSetting/ai_setting_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget createAiSettingPage() {
  return const ProviderScope(child: MaterialApp(home: AiSettingPage()));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('isValidEndpointUrl', () {
    test('returns true for empty or whitespace string', () {
      expect(isValidEndpointUrl(''), isTrue);
      expect(isValidEndpointUrl('   '), isTrue);
    });

    test('returns true for valid https remote endpoints', () {
      expect(isValidEndpointUrl('https://api.openai.com/v1'), isTrue);
      expect(isValidEndpointUrl('https://api.deepseek.com/v1'), isTrue);
    });

    test('returns true for http local loopback hosts', () {
      expect(isValidEndpointUrl('http://localhost:8080/v1'), isTrue);
      expect(isValidEndpointUrl('http://127.0.0.1:11434/v1'), isTrue);
      expect(isValidEndpointUrl('http://[::1]:11434/v1'), isTrue);
    });

    test('returns false for unencrypted remote http endpoints', () {
      expect(isValidEndpointUrl('http://api.openai.com/v1'), isFalse);
      expect(isValidEndpointUrl('http://example.com/api'), isFalse);
    });

    test('returns false for invalid or non-http(s) scheme URLs', () {
      expect(isValidEndpointUrl('ftp://example.com'), isFalse);
      expect(isValidEndpointUrl('not_a_url'), isFalse);
      expect(isValidEndpointUrl('https://'), isFalse);
    });
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
}
