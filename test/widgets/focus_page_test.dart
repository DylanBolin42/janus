import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/pages/FocusPage/focus_page.dart';

void main() {
  testWidgets('Focuspage renders without crashing', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Focuspage()));

    expect(tester.takeException(), isNull);
    expect(find.byType(Placeholder), findsOneWidget);
  });
}
