/// A task snapshot for scheduling. EST is an estimate, never actual work time.
class SchedulingTask {
  const SchedulingTask({
    required this.id,
    required this.priority,
    this.status = 0,
    this.deadline,
    this.estimatedDuration,
  });

  final int id;
  final int priority;
  final int status;
  final DateTime? deadline;
  final Duration? estimatedDuration;
}

/// An absolute, half-open interval [start, end). Use separate intervals for
/// daily working hours. Callers resolve calendar dates/time zones before calling.
class SchedulingWindow {
  const SchedulingWindow(this.start, this.end);

  final DateTime start;
  final DateTime end;
}

class SchedulerConfig {
  const SchedulerConfig({this.defaultDuration = const Duration(minutes: 30)});

  final Duration defaultDuration;
}

enum PriorityLevel { a, b, c }

/// The unrounded cardo-v1 score from JANUS-26, not a new scheduling score.
class CardoScore {
  const CardoScore._(this.baseContribution, this.urgencyContribution);

  final double baseContribution;
  final double urgencyContribution;
  double get value => baseContribution + urgencyContribution;
  PriorityLevel get level => value >= 70
      ? PriorityLevel.a
      : value >= 40
      ? PriorityLevel.b
      : PriorityLevel.c;

  static CardoScore calculate({
    required int priority,
    required DateTime? deadline,
    required DateTime now,
  }) {
    if (priority < 0 || priority > 3) {
      throw ArgumentError.value(priority, 'priority', 'Expected 0–3');
    }
    final microseconds = deadline
        ?.toUtc()
        .difference(now.toUtc())
        .inMicroseconds;
    final remainingHours = microseconds == null
        ? null
        : (microseconds < 0 ? 0 : microseconds) / Duration.microsecondsPerHour;
    final urgency = remainingHours == null
        ? 0.0
        : 1 / (1 + remainingHours / 24);
    return CardoScore._(100 * 0.625 * (priority / 3), 100 * 0.375 * urgency);
  }
}

enum SchedulingReason {
  cardoPriority,
  missingDeadline,
  priorityUnset,
  defaultDuration,
  deadlineRepair,
}

enum UnscheduledReason {
  invalidInput,
  completed,
  frozen,
  expired,
  insufficientWindow,
  deadlineUnreachable,
  lowerPriorityConflict,
}

class ScheduledBlock {
  ScheduledBlock._(
    this._candidate,
    this.start,
    this.end, {
    required bool repair,
  }) : reasons = List.unmodifiable([
         SchedulingReason.cardoPriority,
         if (_candidate.task.deadline == null) SchedulingReason.missingDeadline,
         if (_candidate.task.priority == 0) SchedulingReason.priorityUnset,
         if (_candidate.usesDefault) SchedulingReason.defaultDuration,
         if (repair) SchedulingReason.deadlineRepair,
       ]);

  final _Candidate _candidate;
  int get taskId => _candidate.task.id;
  CardoScore get score => _candidate.score;
  Duration get duration => _candidate.duration;
  bool get usesDefaultDuration => _candidate.usesDefault;

  /// Both supplied EST and the fallback are estimates, not actual duration.
  bool get durationIsEstimated => true;
  final DateTime start;
  final DateTime end;
  final List<SchedulingReason> reasons;
}

class UnscheduledTask {
  UnscheduledTask._(
    this.taskId,
    this.reason, {
    this.score,
    List<int> conflicts = const [],
  }) : conflictingTaskIds = List.unmodifiable(conflicts);

  final int taskId;
  final UnscheduledReason reason;
  final CardoScore? score;

  /// Higher-ranked admitted tasks retained instead of this task.
  final List<int> conflictingTaskIds;
}

class ScheduleResult {
  ScheduleResult._(
    this.calculatedAt,
    List<ScheduledBlock> blocks,
    List<UnscheduledTask> unscheduled,
  ) : blocks = List.unmodifiable(blocks),
      unscheduled = List.unmodifiable(unscheduled);

  static const scoringVersion = 'cardo-v1';
  static const schedulingVersion = 'scheduler-v1';
  final DateTime calculatedAt;
  final List<ScheduledBlock> blocks;
  final List<UnscheduledTask> unscheduled;
}

/// Deterministic, single-person, non-preemptive scheduling. No database or UI
/// writes. Each admitted task gets one continuous block, ending by its DDL.
class TaskScheduler {
  const TaskScheduler({this.config = const SchedulerConfig()});

  final SchedulerConfig config;

  ScheduleResult schedule({
    required List<SchedulingTask> tasks,
    required DateTime now,
    required List<SchedulingWindow> windows,
    List<SchedulingWindow> unavailablePeriods = const [],
  }) {
    // JANUS-30 owns unavailable periods. Fail explicitly rather than silently
    // scheduling over a caller's requested break.
    if (unavailablePeriods.isNotEmpty) {
      throw UnsupportedError('Unavailable periods are reserved for JANUS-30');
    }
    if (config.defaultDuration <= Duration.zero) {
      throw ArgumentError('defaultDuration must be positive');
    }
    final ids = <int>{};
    for (final task in tasks) {
      if (!ids.add(task.id)) {
        throw ArgumentError('Duplicate task id: ${task.id}');
      }
    }
    final instant = now.toUtc();
    final available = _normalize(windows, instant);
    final rejected = <UnscheduledTask>[];
    final candidates = <_Candidate>[];
    for (final task in tasks) {
      UnscheduledReason? excluded;
      if (task.priority < 0 ||
          task.priority > 3 ||
          ![-1, 0, 1, 2].contains(task.status)) {
        excluded = UnscheduledReason.invalidInput;
      } else if (task.status == 1) {
        excluded = UnscheduledReason.completed;
      } else if (task.status == -1) {
        excluded = UnscheduledReason.frozen;
      } else if (task.deadline != null && !task.deadline!.isAfter(instant)) {
        excluded = UnscheduledReason.expired;
      } else if (task.estimatedDuration != null &&
          task.estimatedDuration! <= Duration.zero) {
        excluded = UnscheduledReason.invalidInput;
      }
      if (excluded != null) {
        rejected.add(UnscheduledTask._(task.id, excluded));
        continue;
      }
      candidates.add(
        _Candidate(
          task,
          task.estimatedDuration ?? config.defaultDuration,
          CardoScore.calculate(
            priority: task.priority,
            deadline: task.deadline,
            now: instant,
          ),
        ),
      );
    }
    candidates.sort(_rank);
    final admitted = <_Candidate>[];
    var placements = <_Placement>[];
    var repaired = false;
    for (final candidate in candidates) {
      final alone = _pack([candidate], available);
      if (alone == null) {
        final withoutDeadline = _pack(
          [candidate],
          available,
          ignoreDeadlines: true,
        );
        rejected.add(
          UnscheduledTask._(
            candidate.task.id,
            withoutDeadline == null
                ? UnscheduledReason.insufficientWindow
                : UnscheduledReason.deadlineUnreachable,
            score: candidate.score,
          ),
        );
        continue;
      }
      final trial = [...admitted, candidate];
      var plan = _pack(trial, available);
      var repair = false;
      if (plan == null) {
        final edf = [...trial]..sort(_edf);
        plan = _pack(edf, available);
        repair = plan != null;
      }
      if (plan == null) {
        rejected.add(
          UnscheduledTask._(
            candidate.task.id,
            UnscheduledReason.lowerPriorityConflict,
            score: candidate.score,
            conflicts: admitted.map((c) => c.task.id).toList(),
          ),
        );
      } else {
        admitted.add(candidate);
        placements = plan;
        repaired = repair;
      }
    }
    placements.sort((a, b) => a.start.compareTo(b.start));
    rejected.sort((a, b) => a.taskId.compareTo(b.taskId));
    return ScheduleResult._(instant, [
      for (final p in placements)
        ScheduledBlock._(p.candidate, p.start, p.end, repair: repaired),
    ], rejected);
  }
}

class _Candidate {
  const _Candidate(this.task, this.duration, this.score);
  final SchedulingTask task;
  final Duration duration;
  final CardoScore score;
  bool get usesDefault => task.estimatedDuration == null;
}

class _Placement {
  const _Placement(this.candidate, this.start, this.end);
  final _Candidate candidate;
  final DateTime start;
  final DateTime end;
}

int _deadline(_Candidate a, _Candidate b) {
  final ad = a.task.deadline;
  final bd = b.task.deadline;
  if (ad == null) return bd == null ? 0 : 1;
  if (bd == null) return -1;
  return ad.compareTo(bd);
}

int _rank(_Candidate a, _Candidate b) {
  // JANUS-62 requires undated tasks below dated tasks. Within each group,
  // retain the JANUS-26 score / deadline / id ordering without changing scores.
  if ((a.task.deadline == null) != (b.task.deadline == null)) {
    return a.task.deadline == null ? 1 : -1;
  }
  final score = b.score.value.compareTo(a.score.value);
  if (score != 0) return score;
  final deadline = _deadline(a, b);
  return deadline != 0 ? deadline : a.task.id.compareTo(b.task.id);
}

int _edf(_Candidate a, _Candidate b) {
  final deadline = _deadline(a, b);
  return deadline != 0 ? deadline : _rank(a, b);
}

List<SchedulingWindow> _normalize(
  List<SchedulingWindow> windows,
  DateTime now,
) {
  final sorted = <SchedulingWindow>[];
  for (final window in windows) {
    if (!window.end.isAfter(window.start)) {
      throw ArgumentError('Window end must be after start');
    }
    if (window.end.isAfter(now)) {
      sorted.add(
        SchedulingWindow(
          window.start.isBefore(now) ? now : window.start.toUtc(),
          window.end.toUtc(),
        ),
      );
    }
  }
  sorted.sort((a, b) => a.start.compareTo(b.start));
  final merged = <SchedulingWindow>[];
  for (final window in sorted) {
    if (merged.isEmpty || window.start.isAfter(merged.last.end)) {
      merged.add(window);
    } else if (window.end.isAfter(merged.last.end)) {
      merged[merged.length - 1] = SchedulingWindow(
        merged.last.start,
        window.end,
      );
    }
  }
  return merged;
}

List<_Placement>? _pack(
  List<_Candidate> candidates,
  List<SchedulingWindow> windows, {
  bool ignoreDeadlines = false,
}) {
  final free = [...windows];
  final plan = <_Placement>[];
  for (final candidate in candidates) {
    var placed = false;
    for (var i = 0; i < free.length; i++) {
      final slot = free[i];
      // Compare duration before adding to avoid DateTime overflow for huge EST.
      if (candidate.duration > slot.end.difference(slot.start)) continue;
      final end = slot.start.add(candidate.duration);
      if (!ignoreDeadlines &&
          candidate.task.deadline != null &&
          end.isAfter(candidate.task.deadline!)) {
        continue;
      }
      plan.add(_Placement(candidate, slot.start, end));
      if (end == slot.end) {
        free.removeAt(i);
      } else {
        free[i] = SchedulingWindow(end, slot.end);
      }
      placed = true;
      break;
    }
    if (!placed) return null;
  }
  return plan;
}
