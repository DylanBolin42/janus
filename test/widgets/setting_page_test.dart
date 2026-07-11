import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/pages/SettingPage/settingPage.dart';

void main() {
  testWidgets('SettingPage renders with title', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Settingpage()));
    await tester.pump();

    // AppBar title from RouteDisplayName
    expect(find.text('设置'), findsWidgets);
  });

  testWidgets('SettingPage has all six setting tiles', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Settingpage()));
    await tester.pump();

    expect(find.text('通用'), findsOneWidget);
    expect(find.text('通知'), findsOneWidget);
    expect(find.text('专注'), findsOneWidget);
    expect(find.text('数据'), findsOneWidget);
    expect(find.text('同步'), findsOneWidget);
    expect(find.text('关于'), findsOneWidget);
  });

  testWidgets('SettingPage has back button', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Settingpage()));
    await tester.pump();

    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
  });

  testWidgets('SettingPage renders without crashing', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Settingpage()));
    await tester.pump();

    // Just verify it renders without errors
    expect(tester.takeException(), isNull);
  });
}
