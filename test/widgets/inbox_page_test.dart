import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/pages/Inbox/InboxPage.dart';

void main() {
  testWidgets('InboxPage displays welcome message', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: InboxPage()));

    expect(find.text('Welcome to Janus'), findsOneWidget);
    expect(find.byType(Center), findsOneWidget);
  });
}
