import 'package:flutter_test/flutter_test.dart';
import 'package:janus/scheduling/task_scheduler.dart';

void main() {
  // Fixed Europe/Berlin 2026 transition fixtures, resolved at the caller boundary:
  // Mar 29: 02:00 CET -> 03:00 CEST. Oct 25: 03:00 CEST -> 02:00 CET.
  // Explicit offsets make these independent of the test machine's local zone.
  final fixtures = [
    (
      'spring gap',
      '2026-03-29T01:30:00+01:00',
      '2026-03-29T03:30:00+02:00',
      DateTime.utc(2026, 3, 29, 0, 30),
      DateTime.utc(2026, 3, 29, 1, 30),
    ),
    (
      'autumn repeated hour',
      '2026-10-25T02:30:00+02:00',
      '2026-10-25T02:30:00+01:00',
      DateTime.utc(2026, 10, 25, 0, 30),
      DateTime.utc(2026, 10, 25, 1, 30),
    ),
  ];
  for (final (name, startText, endText, startUtc, endUtc) in fixtures) {
    test('Berlin $name preserves absolute elapsed duration', () {
      final start = DateTime.parse(startText);
      final end = DateTime.parse(endText);
      final result = const TaskScheduler().schedule(
        now: start,
        windows: [SchedulingWindow(start, end)],
        tasks: [
          SchedulingTask(
            id: 1,
            priority: 3,
            deadline: end,
            estimatedDuration: const Duration(hours: 1),
          ),
          const SchedulingTask(
            id: 2,
            priority: 0,
            estimatedDuration: Duration(minutes: 1),
          ),
        ],
      );
      expect(result.blocks.single.start, startUtc);
      expect(result.blocks.single.end, endUtc);
      expect(result.blocks.single.duration, const Duration(hours: 1));
      expect(
        result.unscheduled.single.reason,
        UnscheduledReason.lowerPriorityConflict,
      );
      final tooLong = const TaskScheduler().schedule(
        now: start,
        windows: [SchedulingWindow(start, end)],
        tasks: [
          const SchedulingTask(
            id: 3,
            priority: 3,
            estimatedDuration: Duration(minutes: 90),
          ),
        ],
      );
      expect(
        tooLong.unscheduled.single.reason,
        UnscheduledReason.insufficientWindow,
      );
    });
  }
}
