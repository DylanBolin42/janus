import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/pages/TaskPage/task_page.dart';

void main() {
  testWidgets('TaskPage renders without crashing', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TaskPage()));

    expect(tester.takeException(), isNull);
    expect(find.byType(Placeholder), findsOneWidget);
  });
}
