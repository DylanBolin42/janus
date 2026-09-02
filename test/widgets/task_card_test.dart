import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/shared/task_card.dart';

void main() {
  testWidgets('TaskCard renders title, tooltip, and toggles status', (
    WidgetTester tester,
  ) async {
    bool toggledState = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskCard(
            title: '完成周报编写',
            description: '总结本周系统设计与集成测试进度',
            isCompleted: false,
            priority: '高',
            ddl: DateTime(2026, 3, 30, 18, 0),
            est: const TimeOfDay(hour: 1, minute: 30),
            onToggle: (val) {
              toggledState = val;
            },
          ),
        ),
      ),
    );

    expect(find.text('完成周报编写'), findsOneWidget);
    expect(find.text('总结本周系统设计与集成测试进度'), findsOneWidget);
    expect(find.text('高'), findsOneWidget);

    // Verify Tooltip presence
    expect(find.byType(Tooltip), findsOneWidget);
    final Tooltip tooltip = tester.widget(find.byType(Tooltip));
    expect(tooltip.message, '标记为已完成');

    // Tap check indicator button
    await tester.tap(find.byType(Tooltip));
    await tester.pumpAndSettle();

    expect(toggledState, isTrue);
  });
}
