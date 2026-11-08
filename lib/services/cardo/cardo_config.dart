import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

/// Immutable, validated snapshot. No caller can mutate a running batch's policy.
class CardoConfig {
  final Map<String, dynamic> _data;
  final int revision;
  final String source;
  final DateTime loadedAt;
  final List<String> warnings;
  CardoConfig._(this._data, this.revision, this.source, this.warnings)
    : loadedAt = DateTime.now().toUtc();
  Map<String, dynamic> get parameters =>
      jsonDecode(jsonEncode(_data)) as Map<String, dynamic>;
  int get version => _data['version'] as int;
  String get scoringVersion => version == 1 ? 'cardo-v1' : 'cardo-v2';
  Map<String, dynamic> factor(String key) =>
      parameters['factors'][key] as Map<String, dynamic>;
  double threshold(String key) => (_data['thresholds'][key] as num).toDouble();
}

/// Read-only observation of effective state and the latest attempt.
class CardoConfigDiagnostics {
  final CardoConfig effective;
  final Map<String, double> effectiveWeights;
  final DateTime? lastAttemptAt;
  final String? attemptedSource, error;
  final String status;
  const CardoConfigDiagnostics(
    this.effective,
    this.effectiveWeights,
    this.lastAttemptAt,
    this.attemptedSource,
    this.status,
    this.error,
  );
}

Map<String, dynamic> _factor(
  bool enabled,
  double weight,
  Map<String, dynamic> normalization, [
  Map<String, dynamic> params = const {},
]) => {
  'enabled': enabled,
  'weight': weight,
  'normalization': normalization,
  'params': params,
};

Map<String, dynamic> _defaults(int version) => {
  'version': version,
  'factors': {
    'base': _factor(true, .625, {
      'priority_values': [0, 1 / 3, 2 / 3, 1],
    }),
    'urgency': _factor(true, .375, {'half_life_hours': 24, 'missing_value': 0}),
    'estimated_duration': _factor(
      false,
      0,
      {'scale_minutes': 60},
      {'default_minutes': 30},
    ),
    if (version == 2) ...{
      'aging': _factor(false, 0, {'scale_days': 30}),
      'decay': _factor(false, 0, {'lambda_per_day': .01}),
      'dependency': _factor(false, 0, {'scale_minutes': 60}),
      'efficiency': _factor(false, 0, {}),
      'success': _factor(false, 0, {}),
      'context': _factor(false, 0, {}),
      'feedback': _factor(false, 0, {}),
      'goal': _factor(false, 0, {}),
    },
  },
  'thresholds': {'b_min': 40, 'a_min': 70},
};

/// Whole-snapshot replacement; errors never change the effective configuration.
/// Loads are serialized, including read failures and missing-file fallback.
class CardoConfigService {
  CardoConfig get current => _current;
  late CardoConfig _current = CardoConfig._(
    _defaults(1),
    0,
    'builtin',
    const [],
  );
  DateTime? lastAttemptAt;
  String? attemptedSource;
  String lastStatus = 'builtin';
  String? lastError;
  Future<void> _queue = Future.value();
  final List<void Function()> _listeners = [];
  CardoConfigDiagnostics get diagnostics {
    final factors = current.parameters['factors'] as Map<String, dynamic>;
    final weights = <String, double>{
      for (final e in factors.entries)
        if (e.value['enabled'] == true)
          e.key: (e.value['weight'] as num).toDouble(),
    };
    final sum = weights.values.fold(0.0, (a, b) => a + b);
    return CardoConfigDiagnostics(
      current,
      Map.unmodifiable(weights.map((k, v) => MapEntry(k, v / sum))),
      lastAttemptAt,
      attemptedSource,
      lastStatus,
      lastError,
    );
  }

  bool _disposed = false;
  Timer? _fileTimer;
  int _watchGeneration = 0;
  int _requestGeneration = 0;
  String? _lastText;
  String? _lastPath;

  /// Polling also handles atomic rename and deletion of the parent directory.
  Future<void> watchFile(
    String path, {
    Duration interval = const Duration(seconds: 2),
  }) async {
    if (_disposed) return;
    final generation = ++_watchGeneration;
    _fileTimer?.cancel();
    await reloadFile(path);
    if (_disposed || generation != _watchGeneration) return;
    _fileTimer = Timer.periodic(interval, (_) => unawaited(reloadFile(path)));
  }

  void dispose() {
    _disposed = true;
    _fileTimer?.cancel();
    _listeners.clear();
  }

  void addListener(void Function() listener) => _listeners.add(listener);
  void removeListener(void Function() listener) => _listeners.remove(listener);

  bool replaceJson(String text, {String source = 'injected'}) {
    ++_requestGeneration;
    lastAttemptAt = DateTime.now().toUtc();
    attemptedSource = source;
    try {
      final (data, warnings) = _parseCandidate(text);
      _publish(data, warnings, source);
      return true;
    } on FormatException catch (error) {
      lastStatus = 'rejected';
      lastError = error.message;
      return false;
    }
  }

  void _publish(
    Map<String, dynamic> data,
    List<String> warnings,
    String source,
  ) {
    final next = CardoConfig._(
      data,
      current.revision + 1,
      source,
      List.unmodifiable(warnings),
    );
    _current = next;
    lastStatus = 'success';
    lastError = null;
    for (final listener in List.of(_listeners)) {
      listener();
    }
  }

  Future<void> reloadFile(String path) {
    final generation = ++_requestGeneration;
    final next = _queue.then((_) async {
      if (generation != _requestGeneration || _disposed) return;
      lastAttemptAt = DateTime.now().toUtc();
      attemptedSource = path;
      try {
        final file = File(path);
        final exists = await file.exists();
        if (generation != _requestGeneration || _disposed) return;
        if (!exists) {
          if (current.source != 'builtin') replaceJson('{}', source: 'builtin');
          _lastText = null;
          _lastPath = null;
          attemptedSource = path;
          lastStatus = 'fallback';
          lastError = 'file_missing';
          return;
        }
        // Read at most limit+1, even if the file grows between stat and read.
        final bytes = <int>[];
        await for (final chunk in file.openRead(0, 65537)) {
          bytes.addAll(chunk);
        }
        if (bytes.length > 65536) {
          throw const FormatException('size: exceeds 65536 bytes');
        }
        final text = utf8.decode(bytes);
        if (text == _lastText &&
            path == _lastPath &&
            current.source == file.absolute.path &&
            lastStatus != 'rejected') {
          return;
        }
        final (data, warnings) = await _parseOffThread(text);
        if (generation != _requestGeneration || _disposed) return;
        attemptedSource = file.absolute.path;
        _publish(data, warnings, file.absolute.path);
        _lastText = text;
        _lastPath = path;
      } catch (error) {
        if (generation != _requestGeneration || _disposed) return;
        lastStatus = 'rejected';
        lastError = error.toString();
      }
    });
    _queue = next;
    return next;
  }
}

/// A top-level closure captures only the bounded text, never database/UI state.
Future<(Map<String, dynamic>, List<String>)> _parseOffThread(String text) =>
    Isolate.run(() => _parseCandidate(text));

(Map<String, dynamic>, List<String>) _parseCandidate(String text) {
  if (utf8.encode(text).length > 65536) {
    throw const FormatException('size: exceeds 65536 bytes');
  }
  _StrictJson(text).validate();
  final raw = jsonDecode(text);
  if (raw is! Map<String, dynamic>) {
    throw const FormatException('root: expected object');
  }
  final version = raw.containsKey('version') ? raw['version'] : 1;
  if (version is! int || (version != 1 && version != 2)) {
    throw const FormatException('version: expected integer 1 or 2');
  }
  final warnings = <String>[];
  final data = _merge(raw, _defaults(version), '', warnings);
  _validate(data);
  final factors = data['factors'] as Map<String, dynamic>;
  for (final name in ['base', 'urgency']) {
    if (factors[name]['enabled'] == false) warnings.add('${name}_disabled');
  }
  return (data, warnings);
}

Map<String, dynamic> _merge(
  Map<String, dynamic> raw,
  Map<String, dynamic> defaults,
  String path,
  List<String> warnings,
) {
  final result = <String, dynamic>{};
  for (final key in raw.keys) {
    if (!defaults.containsKey(key)) warnings.add('unknown_field:$path$key');
  }
  for (final entry in defaults.entries) {
    final key = entry.key, expected = entry.value;
    if (!raw.containsKey(key)) {
      warnings.add('defaulted_field:$path$key');
      result[key] = expected;
      continue;
    }
    final value = raw[key];
    if (expected is Map<String, dynamic>) {
      if (value is! Map<String, dynamic>) {
        throw FormatException('$path$key: expected object');
      }
      result[key] = _merge(value, expected, '$path$key.', warnings);
    } else {
      if (expected is bool && value is! bool) {
        throw FormatException('$path$key: expected boolean');
      }
      if (expected is num && (value is! num || !value.isFinite)) {
        throw FormatException('$path$key: expected finite number');
      }
      result[key] = value;
    }
  }
  return result;
}

void _validate(Map<String, dynamic> data) {
  void range(dynamic value, double min, double max, String path) {
    if (value is! num || !value.isFinite || value < min || value > max) {
      throw FormatException('$path: expected finite number in [$min,$max]');
    }
  }

  final factors = data['factors'] as Map<String, dynamic>;
  double sum = 0;
  for (final entry in factors.entries) {
    final f = entry.value as Map<String, dynamic>;
    range(f['weight'], 0, 10, 'factors.${entry.key}.weight');
    if (f['enabled'] == true) sum += (f['weight'] as num).toDouble();
    final n = f['normalization'] as Map<String, dynamic>;
    for (final e in n.entries) {
      switch (e.key) {
        case 'priority_values':
          final values = e.value;
          if (values is! List || values.length != 4) {
            throw const FormatException(
              'priority_values: expected four numbers',
            );
          }
          for (final v in values) {
            range(v, 0, 1, 'priority_values');
          }
          if (values.first != 0 ||
              values.last != 1 ||
              List.generate(
                3,
                (i) => (values[i] as num) <= (values[i + 1] as num),
              ).contains(false)) {
            throw const FormatException(
              'priority_values: expected monotonic 0..1',
            );
          }
        case 'half_life_hours':
          range(
            e.value,
            .25,
            8760,
            'factors.${entry.key}.normalization.${e.key}',
          );
        case 'missing_value':
          range(e.value, 0, 0, 'factors.${entry.key}.normalization.${e.key}');
        case 'scale_minutes':
          range(
            e.value,
            1,
            10080,
            'factors.${entry.key}.normalization.${e.key}',
          );
        case 'scale_days':
          range(
            e.value,
            1,
            36500,
            'factors.${entry.key}.normalization.${e.key}',
          );
        case 'lambda_per_day':
          range(e.value, 0, 1, 'factors.${entry.key}.normalization.${e.key}');
      }
    }
  }
  final minutes = factors['estimated_duration']['params']['default_minutes'];
  range(minutes, 1, 10080, 'default_minutes');
  if (minutes is! int) {
    throw const FormatException('default_minutes: expected integer');
  }
  if (data['version'] == 1) {
    final f = factors['estimated_duration'];
    if (f['enabled'] || f['weight'] != 0) {
      throw const FormatException('unsupported_factor:estimated_duration');
    }
    if (!factors['base']['enabled'] && !factors['urgency']['enabled']) {
      throw const FormatException('factors: base or urgency required');
    }
  }
  if (sum < .000001) {
    throw const FormatException(
      'factors: expected enabled weight sum >= 0.000001',
    );
  }
  final t = data['thresholds'];
  range(t['b_min'], 0, 100, 'thresholds.b_min');
  range(t['a_min'], 0, 100, 'thresholds.a_min');
  if (t['b_min'] <= 0 || t['b_min'] >= t['a_min'] || t['a_min'] >= 100) {
    throw const FormatException('thresholds: expected 0 < b_min < a_min < 100');
  }
}

/// Token walk before jsonDecode: rejects duplicate keys and limits nesting.
class _StrictJson {
  final String text;
  int i = 0;
  _StrictJson(this.text);
  void ws() {
    while (i < text.length && ' \n\r\t'.contains(text[i])) {
      i++;
    }
  }

  Never fail() =>
      throw FormatException('json: invalid or duplicate key', text, i);
  String string() {
    final start = i++;
    while (i < text.length) {
      if (text[i] == '\\') {
        i += 2;
        continue;
      }
      if (text[i++] == '"') {
        return jsonDecode(text.substring(start, i)) as String;
      }
    }
    fail();
  }

  void value(int depth) {
    ws();
    if (i >= text.length) fail();
    final c = text[i];
    if (c == '"') {
      string();
      return;
    }
    if (c == '{' || c == '[') {
      if (depth >= 16) fail();
      i++;
      ws();
      final end = c == '{' ? '}' : ']';
      final keys = <String>{};
      if (i < text.length && text[i] == end) {
        i++;
        return;
      }
      while (true) {
        ws();
        if (c == '{') {
          if (i >= text.length || text[i] != '"') fail();
          if (!keys.add(string())) fail();
          ws();
          if (i >= text.length || text[i++] != ':') fail();
        }
        value(depth + 1);
        ws();
        if (i >= text.length) fail();
        if (text[i] == end) {
          i++;
          return;
        }
        if (text[i++] != ',') fail();
      }
    }
    final start = i;
    while (i < text.length && !' \n\r\t,]}'.contains(text[i])) {
      i++;
    }
    if (start == i) fail();
    final decoded = jsonDecode(text.substring(start, i));
    if (decoded is num && !decoded.isFinite) fail();
  }

  void validate() {
    value(0);
    ws();
    if (i != text.length) fail();
  }
}
