import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:janus/scheduling/task_scheduler.dart';

final now = DateTime.utc(2026, 11, 8, 9);
DateTime at(int minutes) => now.add(Duration(minutes: minutes));
SchedulingTask task(
  int id, {
  int priority = 2,
  int? ddl,
  int? minutes = 30,
  int status = 0,
}) => SchedulingTask(
  id: id,
  priority: priority,
  status: status,
  deadline: ddl == null ? null : at(ddl),
  estimatedDuration: minutes == null ? null : Duration(minutes: minutes),
);
ScheduleResult plan(
  List<SchedulingTask> tasks, {
  int length = 480,
  List<SchedulingWindow>? windows,
}) => const TaskScheduler().schedule(
  tasks: tasks,
  now: now,
  windows: windows ?? [SchedulingWindow(now, at(length))],
);
List<int> ids(ScheduleResult result) =>
    result.blocks.map((b) => b.taskId).toList();

void main() {
  group('cardo-v1 reference contract', () {
    test('matches JANUS-26 numeric examples and missing DDL weights', () {
      final examples = [
        (3, 360, 92.5, PriorityLevel.a),
        (2, 4320, 51.0416666667, PriorityLevel.b),
        (0, -360, 37.5, PriorityLevel.c),
        (3, null, 62.5, PriorityLevel.b),
        (3, 5760, 70.0, PriorityLevel.a),
      ];
      for (final (priority, ddl, value, level) in examples) {
        final score = CardoScore.calculate(
          priority: priority,
          deadline: ddl == null ? null : at(ddl),
          now: now,
        );
        expect(score.value, closeTo(value, 1e-9));
        expect(score.level, level);
        expect(score.value, score.baseContribution + score.urgencyContribution);
      }
    });
    test('uses subsecond precision and UTC instants', () {
      final ddl = at(1440).add(const Duration(milliseconds: 500));
      final score = CardoScore.calculate(priority: 3, deadline: ddl, now: now);
      expect(score.urgencyContribution, lessThan(18.75));
      expect(
        CardoScore.calculate(
          priority: 3,
          deadline: ddl.toLocal(),
          now: now.toLocal(),
        ).value,
        score.value,
      );
      expect(
        () => CardoScore.calculate(priority: 4, deadline: null, now: now),
        throwsArgumentError,
      );
    });
    test('does not round a B score into A', () {
      final score = CardoScore.calculate(
        priority: 3,
        deadline: at(5761),
        now: now,
      );
      expect(score.value, lessThan(70));
      expect(score.level, PriorityLevel.b);
    });
  });

  test('empty input and empty/elapsed windows', () {
    expect(plan([]).blocks, isEmpty);
    expect(
      plan([task(1)], windows: []).unscheduled.single.reason,
      UnscheduledReason.insufficientWindow,
    );
    expect(
      plan([task(1)], windows: [SchedulingWindow(at(-60), now)]).blocks,
      isEmpty,
    );
  });
  test('returns concrete, adjacent, non-overlapping blocks', () {
    final result = plan([task(2, ddl: 180), task(1, ddl: 120)]);
    expect(ids(result), [1, 2]);
    expect(result.blocks.first.start, now);
    expect(result.blocks.first.end, at(30));
    expect(result.blocks.last.start, at(30));
    expect(result.blocks.last.end, at(60));
    expect(result.unscheduled, isEmpty);
  });
  test(
    'EDF repairs high-score far-DDL order to save urgent low-score task',
    () {
      final result = plan([
        task(1, priority: 3, ddl: 600, minutes: 60),
        task(2, priority: 0, ddl: 30),
      ], length: 90);
      expect(ids(result), [2, 1]);
      expect(result.blocks.first.end, at(30));
      expect(result.blocks.last.end, at(90));
      expect(
        result.blocks.last.score.value,
        greaterThan(result.blocks.first.score.value),
      );
      expect(
        result.blocks.every(
          (b) => b.reasons.contains(SchedulingReason.deadlineRepair),
        ),
        isTrue,
      );
      expect(result.unscheduled, isEmpty);
    },
  );
  test(
    'keeps long-term important work first when both deadlines remain feasible',
    () {
      final result = plan([
        task(1, priority: 3, ddl: 600),
        task(2, priority: 0, ddl: 120),
      ]);
      expect(ids(result), [1, 2]);
      expect(
        result.blocks.first.reasons,
        isNot(contains(SchedulingReason.deadlineRepair)),
      );
    },
  );
  test('DDL candidates precede undated tasks even with lower score', () {
    expect(ids(plan([task(1, priority: 3), task(2, priority: 0, ddl: 600)])), [
      2,
      1,
    ]);
  });
  test('all undated tasks use score then stable numeric id', () {
    final result = plan([
      task(3, priority: 1),
      task(2, priority: 3),
      task(1, priority: 3),
    ]);
    expect(ids(result), [1, 2, 3]);
    expect(
      result.blocks.every(
        (b) => b.reasons.contains(SchedulingReason.missingDeadline),
      ),
      isTrue,
    );
  });
  test('same score and DDL use id regardless of input order', () {
    expect(ids(plan([task(9, ddl: 180), task(2, ddl: 180)])), [2, 9]);
  });
  test(
    'reports overload tradeoff and preserves higher-ranked admitted work',
    () {
      final result = plan([
        task(1, priority: 3, ddl: 180, minutes: 60),
        task(2, priority: 0, ddl: 30),
      ], length: 60);
      expect(ids(result), [1]);
      expect(
        result.unscheduled.single.reason,
        UnscheduledReason.lowerPriorityConflict,
      );
      expect(result.unscheduled.single.conflictingTaskIds, [1]);
      expect(result.unscheduled.single.score, isNotNull);
    },
  );
  test(
    'distinguishes insufficient continuous window from unreachable deadline',
    () {
      final result = plan([
        task(1, minutes: 90),
        task(2, ddl: 10, minutes: 20),
      ], length: 60);
      expect(result.unscheduled.map((t) => t.reason), [
        UnscheduledReason.insufficientWindow,
        UnscheduledReason.deadlineUnreachable,
      ]);
    },
  );
  test('uses configured fallback and marks every duration as estimated', () {
    final result =
        const TaskScheduler(
          config: SchedulerConfig(defaultDuration: Duration(minutes: 45)),
        ).schedule(
          tasks: [task(1, minutes: null), task(2)],
          now: now,
          windows: [SchedulingWindow(now, at(90))],
        );
    expect(result.blocks.first.duration, const Duration(minutes: 45));
    expect(result.blocks.first.usesDefaultDuration, isTrue);
    expect(
      result.blocks.first.reasons,
      contains(SchedulingReason.defaultDuration),
    );
    expect(result.blocks.last.usesDefaultDuration, isFalse);
    expect(result.blocks.every((b) => b.durationIsEstimated), isTrue);
  });
  test(
    'excludes completed, frozen, past and exactly-now DDL; admits planned',
    () {
      final result = plan([
        task(1, status: 1),
        task(2, status: -1),
        task(3, ddl: -1),
        task(4, ddl: 0),
        task(5, status: 2),
      ]);
      expect(ids(result), [5]);
      expect(result.unscheduled.map((t) => t.reason), [
        UnscheduledReason.completed,
        UnscheduledReason.frozen,
        UnscheduledReason.expired,
        UnscheduledReason.expired,
      ]);
    },
  );
  test('invalid task fields are explicit and do not stop valid tasks', () {
    final result = plan([
      task(1, priority: 4),
      task(2, status: 9),
      task(3, minutes: 0),
      task(4, minutes: -5),
      task(5),
    ]);
    expect(ids(result), [5]);
    expect(
      result.unscheduled.every(
        (t) => t.reason == UnscheduledReason.invalidInput,
      ),
      isTrue,
    );
  });
  test('rejects ambiguous IDs, invalid config/windows and reserved breaks', () {
    expect(() => plan([task(1), task(1)]), throwsArgumentError);
    expect(
      () => plan([], windows: [SchedulingWindow(now, now)]),
      throwsArgumentError,
    );
    expect(
      () => const TaskScheduler(
        config: SchedulerConfig(defaultDuration: Duration.zero),
      ).schedule(tasks: [], now: now, windows: []),
      throwsArgumentError,
    );
    expect(
      () => const TaskScheduler().schedule(
        tasks: [],
        now: now,
        windows: [],
        unavailablePeriods: [SchedulingWindow(now, at(30))],
      ),
      throwsUnsupportedError,
    );
  });
  test(
    'normalizes overlapping windows, clips now, and schedules over several days',
    () {
      final result = plan(
        [task(1, minutes: 60), task(2, minutes: 60), task(3, minutes: 60)],
        windows: [
          SchedulingWindow(at(1440), at(1500)),
          SchedulingWindow(at(-60), at(30)),
          SchedulingWindow(at(20), at(120)),
        ],
      );
      expect(result.blocks.map((b) => b.start), [now, at(60), at(1440)]);
      expect(result.blocks.map((b) => b.end), [at(60), at(120), at(1500)]);
    },
  );
  test(
    'does not split tasks across gaps, but backfills gaps with shorter tasks',
    () {
      final result = plan(
        [task(1, priority: 3, minutes: 60), task(2, priority: 1, minutes: 30)],
        windows: [
          SchedulingWindow(now, at(30)),
          SchedulingWindow(at(60), at(120)),
        ],
      );
      expect(ids(result), [2, 1]);
      expect(result.blocks.first.start, now);
      expect(result.blocks.last.start, at(60));
    },
  );
  test('task can end exactly at DDL/window end', () {
    expect(plan([task(1, ddl: 30)], length: 30).blocks.single.end, at(30));
  });
  test('huge EST is rejected without DateTime overflow', () {
    expect(
      plan([task(1, minutes: 100000000000)]).unscheduled.single.reason,
      UnscheduledReason.insufficientWindow,
    );
  });
  test(
    'dense backlog has a complete deterministic partition and valid intervals',
    () {
      final random = Random(62);
      for (var run = 0; run < 30; run++) {
        final tasks = List.generate(
          50,
          (i) => task(
            i,
            priority: random.nextInt(4),
            ddl: i % 5 == 0 ? null : 15 + random.nextInt(500),
            minutes: 5 + random.nextInt(90),
          ),
        );
        final result = plan(tasks);
        final repeated = plan(tasks.reversed.toList());
        expect(ids(result), ids(repeated));
        expect(
          result.blocks.map((b) => b.start),
          repeated.blocks.map((b) => b.start),
        );
        expect(
          result.unscheduled.map((t) => t.reason),
          repeated.unscheduled.map((t) => t.reason),
        );
        expect(
          {...ids(result), ...result.unscheduled.map((t) => t.taskId)}.length,
          tasks.length,
        );
        expect(result.blocks.length + result.unscheduled.length, tasks.length);
        for (var i = 0; i < result.blocks.length; i++) {
          final block = result.blocks[i];
          expect(block.start.isBefore(now), isFalse);
          expect(block.end.isAfter(at(480)), isFalse);
          expect(block.end.difference(block.start), block.duration);
          final ddl = tasks[block.taskId].deadline;
          if (ddl != null) expect(block.end.isAfter(ddl), isFalse);
          if (i > 0) {
            expect(block.start.isBefore(result.blocks[i - 1].end), isFalse);
          }
        }
      }
    },
  );
  test(
    'retains repaired plan after rejection and still admits later small work',
    () {
      final tasks = [
        task(1, priority: 3, ddl: 600, minutes: 60),
        task(2, priority: 1, ddl: 30),
        task(3, priority: 0, ddl: 30),
        task(4, priority: 0, minutes: 15),
      ];
      final result = plan(tasks, length: 105);
      expect(ids(result), [2, 1, 4]);
      expect(result.unscheduled.single.taskId, 3);
      expect(
        result.unscheduled.single.reason,
        UnscheduledReason.lowerPriorityConflict,
      );
      expect(result.blocks.last.end, at(105));
      expect(
        result.blocks.first.reasons,
        contains(SchedulingReason.deadlineRepair),
      );
      final withoutLaterWork = plan(tasks.take(3).toList(), length: 90);
      expect(ids(withoutLaterWork), [2, 1]);
      expect(
        withoutLaterWork.blocks.first.reasons,
        contains(SchedulingReason.deadlineRepair),
      );
    },
  );
  test('outputs are immutable and inputs are not sorted in place', () {
    final tasks = [task(2), task(1)];
    final result = plan(tasks);
    expect(tasks.map((t) => t.id), [2, 1]);
    expect(() => result.blocks.clear(), throwsUnsupportedError);
    expect(() => result.unscheduled.clear(), throwsUnsupportedError);
    expect(() => result.blocks.first.reasons.clear(), throwsUnsupportedError);
  });
}
