import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/pages/SettingPage/subSettingPage/aiSetting/ai_setting_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:janus/providers/settings_provider.dart';

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

  testWidgets('AiSettingPage validates Endpoint input to enforce HTTPS', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AiSettingPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Find the Endpoint text field
    final endpointField = find.byType(GlassTextField).first;
    expect(endpointField, findsOneWidget);

    // Enter an invalid HTTP remote endpoint
    await tester.enterText(endpointField, 'http://api.openai.com/v1');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Should display the HTTPS error message
    expect(find.text('远程端点必须使用HTTPS协议'), findsOneWidget);

    // Verify that the endpoint was NOT saved in settings (stays empty)
    expect(container.read(appSettingsNotifierProvider).value?.endPoint, '');

    // Enter a valid HTTP loopback endpoint
    await tester.enterText(endpointField, 'http://127.0.0.1:8080/v1');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Error message should disappear
    expect(find.text('远程端点必须使用HTTPS协议'), findsNothing);
    expect(container.read(appSettingsNotifierProvider).value?.endPoint, 'http://127.0.0.1:8080/v1');

    // Enter a valid HTTPS remote endpoint
    await tester.enterText(endpointField, 'https://api.deepseek.com/v1');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('远程端点必须使用HTTPS协议'), findsNothing);
    expect(container.read(appSettingsNotifierProvider).value?.endPoint, 'https://api.deepseek.com/v1');
  });

  testWidgets('AiSettingPage updates Model and obfuscates API Key on change', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AiSettingPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Find the Model text field (the 3rd GlassTextField on the page)
    final textFields = find.byType(GlassTextField);
    final modelField = textFields.at(2);

    await tester.enterText(modelField, 'deepseek-chat');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(container.read(appSettingsNotifierProvider).value?.modelName, 'deepseek-chat');

    // Find the API Key text field (the 2nd GlassTextField on the page)
    final apiKeyField = textFields.at(1);
    await tester.enterText(apiKeyField, 'my-super-secret-key');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Verify through the service that the key is stored (and we can retrieve it)
    final service = container.read(settingsServiceProvider);
    final retrievedKey = await service.getApiKey();
    expect(retrievedKey, 'my-super-secret-key');
  });
}
