import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/shared/task_card.dart';

void main() {
  group('TaskCard Performance & Utility Tests', () {
    test('taskPriorityFromString maps Chinese labels correctly', () {
      expect(taskPriorityFromString('紧急'), TaskPriority.urgent);
      expect(taskPriorityFromString('高'), TaskPriority.high);
      expect(taskPriorityFromString('中'), TaskPriority.medium);
      expect(taskPriorityFromString('低'), TaskPriority.low);
      expect(taskPriorityFromString('unknown'), TaskPriority.medium);
    });

    testWidgets('TaskCard renders correctly with optimized priority map', (
      WidgetTester tester,
    ) async {
      final ddl = DateTime(2025, 7, 21, 14, 30);
      const est = TimeOfDay(hour: 1, minute: 30);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Performance Task',
              description: 'Testing task card optimization',
              isCompleted: false,
              priority: '高',
              ddl: ddl,
              est: est,
            ),
          ),
        ),
      );

      expect(find.text('Performance Task'), findsOneWidget);
      expect(find.text('Testing task card optimization'), findsOneWidget);
      expect(find.text('高'), findsOneWidget);
      expect(find.text('07/21 14:30 · 1h 30m'), findsOneWidget);
    });
  });
}
