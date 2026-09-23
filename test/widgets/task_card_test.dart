import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/shared/task_card.dart';

void main() {
  testWidgets('TaskCard custom checkbox presents semantics and toggles',
      (WidgetTester tester) async {
    bool? toggledState;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Buy Groceries',
              isCompleted: false,
              priority: '中',
              ddl: DateTime.now().add(const Duration(hours: 2)),
              est: const TimeOfDay(hour: 1, minute: 30),
              onToggle: (val) {
                toggledState = val;
              },
            ),
          ),
        ),
      ),
    );

    // Verify Semantics for the checkbox
    final checkboxFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.label == 'Buy Groceries' &&
          widget.properties.checked == false &&
          widget.properties.value == 'Incomplete',
    );
    expect(checkboxFinder, findsOneWidget);

    // Tap on the checkbox Semantics node
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    expect(toggledState, isTrue);

    // Verify updated Semantics
    final updatedCheckboxFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.label == 'Buy Groceries' &&
          widget.properties.checked == true &&
          widget.properties.value == 'Completed',
    );
    expect(updatedCheckboxFinder, findsOneWidget);
  });
}
