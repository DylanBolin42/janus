import 'dart:convert';
import 'dart:io';

import 'package:janus/scheduling/task_scheduler.dart';

/// Informational benchmark (no timing assertion). Run in JIT with:
/// fvm dart run scripts/benchmark_scheduler.dart
void main() {
  final now = DateTime.utc(2026, 11, 8, 9);
  stdout.writeln(
    jsonEncode({
      'runtime': Platform.version,
      'os': Platform.operatingSystem,
      'processors': Platform.numberOfProcessors,
      'mode': 'Dart JIT',
      'samples': 5,
    }),
  );
  for (final count in [500, 2000]) {
    for (final overloaded in [false, true]) {
      final windows = [
        SchedulingWindow(
          now,
          now.add(Duration(minutes: overloaded ? 480 : count * 15)),
        ),
      ];
      final tasks = List.generate(
        count,
        (i) => SchedulingTask(
          id: i,
          priority: i % 4,
          deadline: i % 5 == 0
              ? null
              : now.add(
                  Duration(minutes: overloaded ? 60 + i % 600 : count * 15 + i),
                ),
          estimatedDuration: const Duration(minutes: 15),
        ),
      );
      ScheduleResult run() => const TaskScheduler().schedule(
        tasks: tasks,
        now: now,
        windows: windows,
      );
      run(); // One untimed warmup per scenario.
      final samples = <int>[];
      var scheduled = 0;
      for (var i = 0; i < 5; i++) {
        final clock = Stopwatch()..start();
        final result = run();
        clock.stop();
        scheduled = result.blocks.length;
        samples.add(clock.elapsedMicroseconds);
        if (scheduled + result.unscheduled.length != count) {
          throw StateError('Incomplete partition');
        }
      }
      samples.sort();
      stdout.writeln(
        jsonEncode({
          'tasks': count,
          'scenario': overloaded ? 'overloaded 8h window' : 'all fit',
          'scheduled': scheduled,
          'unscheduled': count - scheduled,
          'microseconds': samples,
          'median_ms': samples[2] / 1000,
          'max_ms': samples.last / 1000,
        }),
      );
    }
  }
}
