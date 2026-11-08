// A plain Dart process is required: TZ is process-local and Flutter's test clock
// cannot change the host's timezone. Keep this fixture free of Flutter imports.
import 'dart:convert';
import 'dart:io';

import 'package:janus/models/insight_period.dart';

void main() {
  Map<String, Object> week(DateTime instant) {
    final start = InsightPeriod.week.start(instant);
    final end = InsightPeriod.week.next(start, 1);
    final deadlines = [
      start.toUtc().subtract(const Duration(microseconds: 1)),
      start.toUtc(),
      end.toUtc().subtract(const Duration(microseconds: 1)),
      end.toUtc(),
    ];
    return {
      'start': start.toUtc().toIso8601String(),
      'end': end.toUtc().toIso8601String(),
      'hours': end.difference(start).inHours,
      'included': [
        for (var i = 0; i < deadlines.length; i++)
          if (!deadlines[i].isBefore(start) && deadlines[i].isBefore(end)) i,
      ],
    };
  }

  stdout.writeln(
    jsonEncode({
      'spring': week(DateTime.utc(2026, 3, 8, 12)),
      'autumn': week(DateTime.utc(2026, 11, 1, 12)),
      // The same instant is Sunday in New York and Monday in UTC/Shanghai.
      'switched': week(DateTime.utc(2026, 3, 9, 2)),
    }),
  );
}
