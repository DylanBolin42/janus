import 'dart:math' as math;
import 'cardo_config.dart';

/// Shared input for database, scheduler and draft callers. All durations are minutes.
class CardoInput {
  final int id, priority, status;
  final DateTime? deadline, createdAt;
  final double? estimatedMinutes,
      usedTime,
      criticalPathMinutes,
      historicalEfficiency;
  final int? successes, attempts, accepted, feedbackCount;
  final bool blocked;
  final bool? resourcesReady;
  final double? energyMatch, goalImpact;
  const CardoInput({
    required this.id,
    required this.priority,
    required this.status,
    this.deadline,
    this.createdAt,
    this.estimatedMinutes,
    this.usedTime,
    this.historicalEfficiency,
    this.criticalPathMinutes,
    this.successes,
    this.attempts,
    this.accepted,
    this.feedbackCount,
    this.blocked = false,
    this.resourcesReady,
    this.energyMatch,
    this.goalImpact,
  });
}

class CardoResult {
  final int taskId, configRevision;
  final String scoringVersion, eligibility;
  final DateTime calculatedAt;
  final double? score;
  final String? level;
  final Map<String, double> factors, contributions;
  final List<String> reasons, warnings;
  const CardoResult({
    required this.taskId,
    required this.configRevision,
    required this.scoringVersion,
    required this.eligibility,
    required this.calculatedAt,
    this.score,
    this.level,
    this.factors = const {},
    this.contributions = const {},
    this.reasons = const [],
    this.warnings = const [],
  });
}

/// The sole formula entry point. Capture one config and clock for the entire batch.
class CardoScoringService {
  final CardoConfigService configs;
  CardoScoringService(this.configs);
  List<CardoResult> calculateBatch(
    List<CardoInput> tasks, {
    required DateTime now,
  }) {
    final snapshot = configs.current;
    final results = tasks
        .map((t) => calculate(t, now: now, config: snapshot))
        .toList();
    final byId = {for (final t in tasks) t.id: t};
    results.sort((a, b) {
      final score = (b.score ?? -1).compareTo(a.score ?? -1);
      if (score != 0) return score;
      final ad = byId[a.taskId]!.deadline, bd = byId[b.taskId]!.deadline;
      final deadline = ad == null
          ? (bd == null ? 0 : 1)
          : bd == null
          ? -1
          : ad.compareTo(bd);
      return deadline != 0 ? deadline : a.taskId.compareTo(b.taskId);
    });
    return List.unmodifiable(results);
  }

  CardoResult calculate(
    CardoInput task, {
    required DateTime now,
    CardoConfig? config,
  }) {
    final c = config ?? configs.current;
    CardoResult excluded(String eligibility, String reason) => CardoResult(
      taskId: task.id,
      configRevision: c.revision,
      scoringVersion: c.scoringVersion,
      eligibility: eligibility,
      calculatedAt: now.toUtc(),
      reasons: [reason],
    );
    if (task.priority < 0 ||
        task.priority > 3 ||
        ![-1, 0, 1, 2].contains(task.status)) {
      return excluded(
        'invalid_input',
        'priority/status outside supported domain',
      );
    }
    if (task.status == 1 || task.status == -1) {
      return excluded('excluded', 'completed_or_frozen');
    }
    if (task.blocked) return excluded('excluded', 'dependency_unfinished');
    if (task.resourcesReady == false) {
      return excluded('excluded', 'resources_unavailable');
    }
    final warnings = <String>[], reasons = <String>[];
    if (task.priority == 0) warnings.add('priority_unset_or_zero');
    final hours = task.deadline
        ?.toUtc()
        .difference(now.toUtc())
        .inMicroseconds
        .toDouble();
    if (hours == null) {
      warnings.add('missing_deadline');
    } else if (hours <= 0) {
      warnings.add('overdue_hours:${-hours / 3600000000}');
    }
    if (task.deadline != null && !task.deadline!.isUtc) {
      warnings.add('deadline_timezone:${task.deadline!.timeZoneName}');
    }
    final age = task.createdAt == null
        ? null
        : math.max(
            0.0,
            now.toUtc().difference(task.createdAt!.toUtc()).inMicroseconds /
                86400000000,
          );
    final f = <String, double>{}, weights = <String, double>{};
    final registered = (c.parameters['factors'] as Map<String, dynamic>).keys;
    double? positive(double? value) =>
        value != null && value.isFinite && value > 0 ? value : null;
    final estimate = positive(task.estimatedMinutes);
    for (final name in registered) {
      final spec = c.factor(name);
      if (spec['enabled'] != true) continue;
      final n = spec['normalization'] as Map<String, dynamic>;
      double? value;
      switch (name) {
        case 'base':
          value = (n['priority_values'][task.priority] as num).toDouble();
        case 'urgency':
          value = hours == null
              ? 0
              : 1 /
                    (1 +
                        math.max(hours / 3600000000, 0) /
                            (n['half_life_hours'] as num));
        case 'estimated_duration':
          value = estimate == null
              ? null
              : 1 / (1 + estimate / (n['scale_minutes'] as num));
        case 'aging':
          value = age == null
              ? null
              : math.min(age / (n['scale_days'] as num), 1);
        case 'decay':
          value = age == null
              ? null
              : math.exp(-(n['lambda_per_day'] as num) * age);
        case 'dependency':
          final path = task.criticalPathMinutes;
          value = path == null
              ? null
              : path / (path + (n['scale_minutes'] as num));
        case 'efficiency':
          final used = positive(task.usedTime);
          value =
              task.historicalEfficiency ??
              (used == null || estimate == null
                  ? null
                  : math.min(estimate / used, 1));
        case 'success':
          if (task.attempts != null &&
              task.attempts! > 0 &&
              task.successes != null) {
            value = (task.successes! + 1) / (task.attempts! + 2);
          }
        case 'context':
          value = task.energyMatch;
        case 'goal':
          value = task.goalImpact;
        case 'feedback':
          if (task.feedbackCount != null &&
              task.feedbackCount! > 0 &&
              task.accepted != null) {
            value = (task.accepted! + 1) / (task.feedbackCount! + 2);
          }
      }
      if (value == null || !value.isFinite || value < 0 || value > 1) {
        warnings.add('missing_data:$name:weight_removed');
        continue;
      }
      f[name] = value;
      weights[name] = (spec['weight'] as num).toDouble();
    }
    final totalWeight = weights.values.fold(0.0, (a, b) => a + b);
    if (totalWeight < .000001) {
      return CardoResult(
        taskId: task.id,
        configRevision: c.revision,
        scoringVersion: c.scoringVersion,
        eligibility: 'insufficient_data',
        calculatedAt: now.toUtc(),
        reasons: const ['no enabled weighted observations'],
        warnings: List.unmodifiable(warnings),
      );
    }
    final contributions = {
      for (final name in f.keys)
        name: 100 * weights[name]! / totalWeight * f[name]!,
    };
    final score = contributions.values
        .fold(0.0, (a, b) => a + b)
        .clamp(0.0, 100.0);
    for (final name in f.keys) {
      reasons.add('$name=${f[name]}; contribution=${contributions[name]}');
    }
    return CardoResult(
      taskId: task.id,
      configRevision: c.revision,
      scoringVersion: c.scoringVersion,
      eligibility: 'eligible',
      calculatedAt: now.toUtc(),
      score: score,
      level: score >= c.threshold('a_min')
          ? 'A'
          : score >= c.threshold('b_min')
          ? 'B'
          : 'C',
      factors: Map.unmodifiable(f),
      contributions: Map.unmodifiable(contributions),
      reasons: List.unmodifiable(reasons),
      warnings: List.unmodifiable(warnings),
    );
  }
}
