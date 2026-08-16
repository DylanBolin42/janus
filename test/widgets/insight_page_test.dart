import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/pages/InsightPage/insight_page.dart';

void main() {
  testWidgets('InsightPage renders without crashing', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: InsightPage()));

    expect(tester.takeException(), isNull);
    expect(find.byType(Placeholder), findsOneWidget);
  });
}
