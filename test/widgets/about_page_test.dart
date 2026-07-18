import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/pages/SettingPage/subSettingPage/aboutPage/about_page.dart';

Widget createAboutPage() {
  return const ProviderScope(child: MaterialApp(home: AboutPage()));
}

void main() {
  testWidgets('AboutPage renders with title', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createAboutPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('关于'), findsWidgets);
  });

  testWidgets('AboutPage has back button', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createAboutPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
  });

  testWidgets('AboutPage shows app name', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createAboutPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Janus'), findsOneWidget);
  });

  testWidgets('AboutPage shows links section', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createAboutPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('版本检测'), findsOneWidget);
    expect(find.text('Issue报告'), findsOneWidget);
    expect(find.text('功能建议'), findsOneWidget);
    expect(find.text('Github主页'), findsOneWidget);
    expect(find.text('开源许可证'), findsOneWidget);
  });

  testWidgets('AboutPage shows open source section', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createAboutPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('开源项目引用清单'), findsOneWidget);
    expect(find.text('AIGC声明清单'), findsOneWidget);
  });

  testWidgets('AboutPage shows action tiles', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createAboutPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Github star'), findsOneWidget);
    expect(find.text('捐赠'), findsOneWidget);
  });

  testWidgets('AboutPage renders without crashing', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createAboutPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
  });
}
