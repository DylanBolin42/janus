import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/services/cardo/cardo_config.dart';
import 'package:janus/services/cardo/cardo_scoring_service.dart';

void main() {
  final now = DateTime.utc(2026, 11, 8, 12);
  late CardoConfigService configs;
  late CardoScoringService scoring;
  setUp(() {
    configs = CardoConfigService();
    scoring = CardoScoringService(configs);
  });
  CardoInput task(int priority, double? hours, {int status = 0}) => CardoInput(
    id: 1,
    priority: priority,
    status: status,
    deadline: hours == null
        ? null
        : now.add(Duration(microseconds: (hours * 3600000000).round())),
  );
  for (final example in [
    (3, 6.0, 92.5, 'A'),
    (2, 72.0, 51.04166666666667, 'B'),
    (0, -6.0, 37.5, 'C'),
    (3, null, 62.5, 'B'),
    (3, 96.0, 70.0, 'A'),
    (1, 0.0, 58.33333333333333, 'B'),
  ]) {
    test('cardo-v1 compatibility $example', () {
      final result = scoring.calculate(task(example.$1, example.$2), now: now);
      expect(result.score, closeTo(example.$3, 1e-10));
      expect(result.level, example.$4);
      expect(result.scoringVersion, 'cardo-v1');
      expect(
        result.contributions.values.fold(0.0, (a, b) => a + b),
        closeTo(result.score!, 1e-10),
      );
    });
  }
  test('exclusions and invalid input do not receive zero scores', () {
    for (final status in [1, -1]) {
      expect(
        scoring.calculate(task(3, 6, status: status), now: now).score,
        isNull,
      );
    }
    expect(
      scoring.calculate(task(4, 6), now: now).eligibility,
      'invalid_input',
    );
    expect(
      scoring.calculate(task(3, 6, status: 99), now: now).eligibility,
      'invalid_input',
    );
    expect(scoring.calculate(task(3, 6, status: 2), now: now).score, 92.5);
  });
  test(
    'missing ddl keeps urgency weight and overdue warning survives disabled urgency',
    () {
      expect(scoring.calculate(task(3, null), now: now).score, 62.5);
      configs.replaceJson('{"factors":{"urgency":{"enabled":false}}}');
      final r = scoring.calculate(task(3, -6), now: now);
      expect(r.score, 100);
      expect(r.warnings.any((w) => w.startsWith('overdue')), isTrue);
    },
  );
  test('config hot replacement and full builtin fallback', () {
    final old = configs.current;
    expect(
      configs.replaceJson(
        '{"factors":{"urgency":{"normalization":{"half_life_hours":48}}}}',
      ),
      isTrue,
    );
    expect(
      scoring.calculate(task(3, 6), now: now).score,
      closeTo(95.83333333333333, 1e-10),
    );
    expect(scoring.calculate(task(3, 6), now: now, config: old).score, 92.5);
    expect(configs.replaceJson('{}'), isTrue);
    expect(scoring.calculate(task(3, 6), now: now).score, 92.5);
    expect(configs.current.warnings, isNotEmpty);
  });
  for (final invalid in [
    '{"version":2.0}',
    '{"version":9}',
    '{"factors":null}',
    '{"factors":{"base":{"enabled":"true"}}}',
    '{"factors":{"base":{"weight":-1}}}',
    '{"factors":{"base":{"weight":0},"urgency":{"weight":0}}}',
    '{"thresholds":{"a_min":30}}',
    '{"factors":{"estimated_duration":{"enabled":true}}}',
    '{"factors":{"estimated_duration":{"params":{"default_minutes":1.5}}}}',
    '{"factors":{"base":{"normalization":{"priority_values":[0,0.8,0.2,1]}}}}',
    '{"version":1,"version":1}',
    '{"version":1,"vers\\u0069on":1}',
    '[1]',
    '{"thresholds":{"a_min":1e999}}',
    '{"x":${'[' * 18}0${']' * 18}}',
    ' ' * 65537,
  ]) {
    test(
      'reject malformed candidate ${invalid.substring(0, invalid.length.clamp(0, 80))}',
      () {
        final old = configs.current;
        expect(configs.replaceJson(invalid), isFalse);
        expect(identical(configs.current, old), isTrue);
        expect(configs.lastError, isNotNull);
      },
    );
  }
  test('unknown fields ignored at each depth with warnings', () {
    expect(
      configs.replaceJson(
        '{"other":1,"factors":{"foo":{},"base":{"params":{"eval":"no"}}}}',
      ),
      isTrue,
    );
    expect(
      configs.current.warnings.where((w) => w.startsWith('unknown_field')),
      hasLength(3),
    );
    expect(configs.current.parameters.containsKey('other'), isFalse);
    final copy = configs.current.parameters;
    copy['version'] = 99;
    expect(configs.current.version, 1);
  });
  test(
    'serialized file reload rejects invalid UTF8 and falls back on removal',
    () async {
      final dir = await Directory.systemTemp.createTemp('cardo');
      addTearDown(() => dir.delete(recursive: true));
      configs.dispose();
      configs = CardoConfigService(configDirectory: () async => dir);
      final f = File('${dir.path}/cardo-config.json');
      await f.writeAsString('{"thresholds":{"a_min":80}}');
      await configs.reloadFile(CardoConfigService.configName);
      final old = configs.current;
      await f.writeAsBytes([255]);
      await configs.reloadFile(CardoConfigService.configName);
      expect(identical(configs.current, old), isTrue);
      await f.delete();
      await configs.reloadFile(CardoConfigService.configName);
      expect(configs.current.source, 'builtin');
      expect(configs.lastStatus, 'fallback');
    },
  );
  test(
    'v2 each optional factor computes, missing data deweights without drifting baseline',
    () {
      for (final entry in {
        'estimated_duration': .5,
        'aging': 1.0,
        'decay': 0.7408182206817179,
        'dependency': .5,
        'efficiency': .5,
        'success': .6,
        'context': .8,
        'feedback': .6,
        'goal': .9,
      }.entries) {
        expect(
          configs.replaceJson(
            jsonEncode({
              'version': 2,
              'factors': {
                entry.key: {'enabled': true, 'weight': 1},
              },
            }),
          ),
          isTrue,
        );
        final input = CardoInput(
          id: 1,
          priority: 3,
          status: 0,
          deadline: now.add(const Duration(hours: 6)),
          createdAt: now.subtract(const Duration(days: 30)),
          estimatedMinutes: 60,
          usedTime: 120,
          criticalPathMinutes: 60,
          successes: 2,
          attempts: 3,
          accepted: 2,
          feedbackCount: 3,
          energyMatch: .8,
          goalImpact: .9,
        );
        final r = scoring.calculate(input, now: now);
        expect(
          r.factors[entry.key],
          closeTo(entry.value, 1e-12),
          reason: entry.key,
        );
        expect(r.score, closeTo((92.5 + 100 * entry.value) / 2, 1e-10));
        expect(r.scoringVersion, 'cardo-v2');
        final missing = scoring.calculate(task(3, 6), now: now);
        expect(missing.score, 92.5);
        expect(
          missing.warnings,
          contains('missing_data:${entry.key}:weight_removed'),
        );
      }
    },
  );
  test(
    'file watch publishes atomic replacement and deletion without restart',
    () async {
      final dir = await Directory.systemTemp.createTemp('cardo-watch');
      configs.dispose();
      configs = CardoConfigService(configDirectory: () async => dir);
      final file = File('${dir.path}/cardo-config.json');
      addTearDown(() async {
        configs.dispose();
        await dir.delete(recursive: true);
      });
      await file.writeAsString('{}');
      await configs.watchFile(
        CardoConfigService.configName,
        interval: const Duration(milliseconds: 10),
      );
      final revision = configs.current.revision;
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(configs.current.revision, revision);
      final temp = File('${dir.path}/new.json');
      await temp.writeAsString('{"thresholds":{"a_min":80}}');
      await temp.rename(file.path);
      for (
        var i = 0;
        i < 100 && configs.current.threshold('a_min') != 80;
        i++
      ) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(configs.current.threshold('a_min'), 80);
      await file.delete();
      for (var i = 0; i < 100 && configs.current.source != 'builtin'; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(configs.current.source, 'builtin');
    },
  );
  test(
    'a pending file request cannot overwrite a newer injected snapshot',
    () async {
      final dir = await Directory.systemTemp.createTemp('cardo-race');
      addTearDown(() => dir.delete(recursive: true));
      configs.dispose();
      configs = CardoConfigService(configDirectory: () async => dir);
      final file = File('${dir.path}/cardo-config.json');
      await file.writeAsString('{"thresholds":{"a_min":90}}');
      final older = configs.reloadFile(CardoConfigService.configName);
      configs.replaceJson('{"thresholds":{"a_min":80}}');
      await older;
      expect(configs.current.threshold('a_min'), 80);
      expect(configs.current.source, 'injected');
    },
  );
  test(
    'fixed sandbox config rejects absolute paths and traversal without echo',
    () async {
      final dir = await Directory.systemTemp.createTemp('cardo-safe');
      addTearDown(() => dir.delete(recursive: true));
      configs.dispose();
      configs = CardoConfigService(configDirectory: () async => dir);
      configs.replaceJson('{"thresholds":{"a_min":80}}');
      final old = configs.current;
      for (final name in [
        '/etc/passwd',
        '../cardo-config.json',
        './cardo-config.json',
        'a/../cardo-config.json',
        r'C:\private\secret',
        '${dir.path}/cardo-config.json',
      ]) {
        await configs.reloadFile(name);
        expect(identical(configs.current, old), isTrue);
        expect(configs.lastStatus, 'rejected');
        expect(configs.attemptedSource, CardoConfigService.configName);
        expect(configs.lastError, 'invalid_configuration_or_path');
        expect(configs.current.source, 'injected');
      }
    },
  );
  test(
    'config rejects file symlinks and directory ancestor symlinks',
    () async {
      final dir = await Directory.systemTemp.createTemp('cardo-links');
      addTearDown(() => dir.delete(recursive: true));
      final real = Directory('${dir.path}/real')..createSync();
      final target = File('${real.path}/cardo-config.json')
        ..writeAsStringSync('{"thresholds":{"a_min":90}}');
      final linkedFile = Link('${dir.path}/cardo-config.json')
        ..createSync(target.path);
      configs.dispose();
      configs = CardoConfigService(configDirectory: () async => dir);
      await configs.reloadFile(CardoConfigService.configName);
      expect(configs.lastStatus, 'rejected');
      expect(configs.current.source, 'builtin');
      await linkedFile.delete();
      final linkedDir = Link('${dir.path}/linked')..createSync(real.path);
      configs.dispose();
      configs = CardoConfigService(
        configDirectory: () async => Directory(linkedDir.path),
      );
      await configs.reloadFile(CardoConfigService.configName);
      expect(configs.lastStatus, 'rejected');
      expect(configs.lastError, 'invalid_configuration_or_path');
      expect(configs.current.source, 'builtin');
    },
  );
  test('gates precede scoring and stable sorting', () {
    expect(
      scoring
          .calculate(
            const CardoInput(id: 1, priority: 3, status: 0, blocked: true),
            now: now,
          )
          .score,
      isNull,
    );
    expect(
      scoring
          .calculate(
            const CardoInput(
              id: 1,
              priority: 3,
              status: 0,
              resourcesReady: false,
            ),
            now: now,
          )
          .score,
      isNull,
    );
    final r = scoring.calculateBatch([
      CardoInput(id: 2, priority: 3, status: 0, deadline: now),
      CardoInput(id: 1, priority: 3, status: 0, deadline: now),
    ], now: now);
    expect(r.map((r) => r.taskId), [1, 2]);
  });
}
