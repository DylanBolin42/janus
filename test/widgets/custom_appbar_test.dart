import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/shared/custom_appbar.dart';

void main() {
  testWidgets('CustomAppbar renders back button with tooltip and semantics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: const CustomAppbar(title: '设置', showBack: true),
          body: const SizedBox(),
        ),
      ),
    );

    expect(find.text('设置'), findsOneWidget);
    expect(find.byTooltip('返回'), findsOneWidget);
    expect(find.bySemanticsLabel('返回'), findsOneWidget);
  });
}
