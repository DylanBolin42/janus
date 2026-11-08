import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  test(
    'local timezone changes and New York DST preserve calendar week bounds',
    () async {
      // flutter_tester lives in <sdk>/bin/cache/artifacts/engine/<platform>/.
      final cache = File(
        Platform.resolvedExecutable,
      ).parent.parent.parent.parent;
      final dart = p.join(
        cache.path,
        'dart-sdk',
        'bin',
        Platform.isWindows ? 'dart.exe' : 'dart',
      );
      final expected = {
        'UTC': [
          '2026-03-02T00:00:00.000Z',
          '2026-03-09T00:00:00.000Z',
          168,
          '2026-10-26T00:00:00.000Z',
          '2026-11-02T00:00:00.000Z',
          168,
          '2026-03-09T00:00:00.000Z',
        ],
        'Asia/Shanghai': [
          '2026-03-01T16:00:00.000Z',
          '2026-03-08T16:00:00.000Z',
          168,
          '2026-10-25T16:00:00.000Z',
          '2026-11-01T16:00:00.000Z',
          168,
          '2026-03-08T16:00:00.000Z',
        ],
        'America/New_York': [
          '2026-03-02T05:00:00.000Z',
          '2026-03-09T04:00:00.000Z',
          167,
          '2026-10-26T04:00:00.000Z',
          '2026-11-02T05:00:00.000Z',
          169,
          '2026-03-02T05:00:00.000Z',
        ],
      };
      for (final zone in expected.keys) {
        final result = await Process.run(
          dart,
          [
            '--packages=.dart_tool/package_config.json',
            'test/fixtures/insight_timezone_probe.dart',
          ],
          environment: {'TZ': zone},
        );
        expect(result.exitCode, 0, reason: '$zone: ${result.stderr}');
        final data =
            jsonDecode(result.stdout as String) as Map<String, dynamic>;
        final spring = data['spring'] as Map<String, dynamic>;
        final autumn = data['autumn'] as Map<String, dynamic>;
        expect(
          [
            spring['start'],
            spring['end'],
            spring['hours'],
            autumn['start'],
            autumn['end'],
            autumn['hours'],
            data['switched']['start'],
          ],
          expected[zone],
          reason: zone,
        );
        for (final week in data.values) {
          expect(week['included'], [
            1,
            2,
          ], reason: '$zone: start inclusive, end exclusive');
        }
      }
    },
    skip: Platform.isWindows
        ? 'IANA TZ selection requires a POSIX host'
        : false,
  );
}
