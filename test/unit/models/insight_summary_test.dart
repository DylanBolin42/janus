import 'package:flutter_test/flutter_test.dart';
import 'package:janus/database/app_database.dart';
import 'package:janus/models/insight_summary.dart';

Task task(int id, DateTime ddl, {int status = 0, int? hours, int? minutes}) =>
    Task(
      id: id,
      status: status,
      title: 'task $id',
      ddl: ddl,
      estHour: hours,
      estMinute: minutes,
      priority: 0,
    );

void main() {
  final start = DateTime(2026, 11, 2);
  final end = DateTime(2026, 11, 9);
  test(
    'half-open deadline range, stable ordering and honest current aggregates',
    () {
      final summary = InsightSummary(
        [
          task(5, end, status: 1),
          task(4, start, status: -1, hours: 10),
          task(3, start, status: 2, minutes: 30),
          task(2, start, status: 1, hours: 1),
          task(1, start.subtract(const Duration(seconds: 1))),
        ],
        start,
        end,
        DateTime(2026, 11, 8),
      );
      expect(summary.tasks.map((t) => t.id), [2, 3, 4]);
      expect(summary.completed, 1);
      expect(summary.frozen, 1);
      expect(summary.completionRate, .5);
      expect(summary.overdue, 1);
      expect(summary.estimatedMinutes, 90);
      expect(summary.estimatedCount, 2);
    },
  );
  test('empty and frozen-only periods have no completion percentage', () {
    expect(InsightSummary([], start, end, start).completionRate, isNull);
    final summary = InsightSummary(
      [task(1, start, status: -1)],
      start,
      end,
      end,
    );
    expect(summary.completionRate, isNull);
    expect(summary.estimatedMinutes, 0);
    expect(summary.overdue, 0);
  });
  test(
    'week/month boundaries use local calendar across years and leap days',
    () {
      expect(
        InsightPeriod.week.start(DateTime(2027, 1, 1)),
        DateTime(2026, 12, 28),
      );
      expect(InsightPeriod.month.next(DateTime(2026, 12), 1), DateTime(2027));
      expect(InsightPeriod.month.next(DateTime(2024, 2), 1), DateTime(2024, 3));
      expect(InsightPeriod.week.next(start, -1), DateTime(2026, 10, 26));
    },
  );
}
