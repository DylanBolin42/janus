import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/shared/task_card.dart';
import 'package:janus/theme/theme.dart';

void main() {
  testWidgets('TaskCard exposes correct Semantics for checkbox', (
    tester,
  ) async {
    bool toggledState = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: TaskCard(
              title: '测试任务',
              isCompleted: false,
              priority: '中',
              ddl: DateTime.now().add(const Duration(hours: 1)),
              est: const TimeOfDay(hour: 1, minute: 0),
              onToggle: (completed) {
                toggledState = completed;
              },
            ),
          ),
        ),
      ),
    );

    // Verify initial checkbox semantics
    final checkboxSemantics = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.label == '完成任务' &&
          widget.properties.value == '未完成' &&
          widget.properties.checked == false &&
          widget.properties.button == true,
    );

    expect(checkboxSemantics, findsOneWidget);

    // Tap checkbox semantics target
    await tester.tap(checkboxSemantics);
    await tester.pumpAndSettle();

    expect(toggledState, isTrue);

    // Verify updated checkbox semantics
    final updatedSemantics = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.label == '完成任务' &&
          widget.properties.value == '已完成' &&
          widget.properties.checked == true &&
          widget.properties.button == true,
    );

    expect(updatedSemantics, findsOneWidget);
  });
}
