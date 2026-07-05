import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/pages/SettingPage/subSettingPage/notificationSetting/notification_setting_page.dart';

Widget createNotificationSettingPage() {
  return const ProviderScope(
    child: MaterialApp(
      home: NotificationSettingPage(),
    ),
  );
}

void main() {
  testWidgets('NotificationSettingPage renders with title', (tester) async {
    await tester.pumpWidget(createNotificationSettingPage());
    await tester.pump();

    expect(find.text('通知'), findsWidgets);
  });

  testWidgets('NotificationSettingPage has back button', (tester) async {
    await tester.pumpWidget(createNotificationSettingPage());
    await tester.pump();

    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
  });

  testWidgets('NotificationSettingPage has notification toggle', (tester) async {
    await tester.pumpWidget(createNotificationSettingPage());
    await tester.pump();

    expect(find.text('是否通知'), findsOneWidget);
  });

  testWidgets('NotificationSettingPage renders without crashing',
      (tester) async {
    await tester.pumpWidget(createNotificationSettingPage());
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
