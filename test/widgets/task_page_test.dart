import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/pages/TimelinePage/timeline_page.dart';

void main() {
  testWidgets('TaskPage renders without crashing', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TimelinePage()));

    expect(tester.takeException(), isNull);
    expect(find.byType(Placeholder), findsOneWidget);
  });
}
