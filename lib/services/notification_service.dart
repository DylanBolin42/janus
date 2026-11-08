import 'dart:convert';

import 'package:janus/database/app_database.dart';
import 'package:janus/models/app_settings.dart';

/// An absolute instant: schedules remain correct across timezone/DST changes.
class NotificationRequest {
  const NotificationRequest(this.id, this.title, this.at, this.style);
  final int id;
  final String title;
  final DateTime at;
  final String style;
  String get fingerprint => jsonEncode([
    'janus.task',
    id,
    title,
    at.toUtc().toIso8601String(),
    style,
  ]);
}

abstract interface class NotificationPlatform {
  Future<bool> permission({bool request = false});
  Future<Map<int, String?>> pending();
  Future<void> schedule(NotificationRequest request);
  Future<void> cancel(int id);
}

/// No catch-up bursts: only future reminders for active tasks are scheduled.
/// Approaching = 24h before DDL; urgent = 6h (same threshold as TaskCard).
/// Reserve four of iOS's 64 pending slots for countdown/future features.
// TODO(JANUS-60): Beyond 60 pending task reminders, refill currently requires
// an app resume or task/settings change. Add an OS background refresh strategy
// and verify platform limits before promising unlimited background coverage.
List<NotificationRequest> planNotifications(
  List<Task> tasks,
  AppSettings settings,
  DateTime now,
) {
  if (!settings.isNotificationEnabled) return [];
  final result = <NotificationRequest>[];
  for (final task in tasks) {
    if (task.status != 0 && task.status != 2) continue;
    // Positive IDs are reserved for tasks; negative IDs for focus/countdown.
    if (task.id <= 0 || task.id > 1073741822) continue;
    for (final urgent in [false, true]) {
      final at = task.ddl.subtract(Duration(hours: urgent ? 6 : 24));
      if (!at.isAfter(now)) continue;
      result.add(
        NotificationRequest(
          task.id * 2 + (urgent ? 1 : 0),
          '${urgent ? '任务紧迫' : '任务临近'}：${task.title}',
          at,
          urgent
              ? settings.urgentNotificationStyle.name
              : settings.approachingNotificationStyle.name,
        ),
      );
    }
  }
  result.sort((a, b) {
    final time = a.at.compareTo(b.at);
    return time == 0 ? a.id.compareTo(b.id) : time;
  });
  return result.take(60).toList();
}

/// Serializes reconciliation so an older DB/settings snapshot cannot win a race.
/// The OS plugin persists pending requests and restores Android alarms on boot.
class NotificationService {
  NotificationService(this.platform, {DateTime Function()? clock})
    : clock = clock ?? DateTime.now;
  final NotificationPlatform platform;
  final DateTime Function() clock;
  Future<void> _queue = Future.value();

  Future<T> _serialize<T>(Future<T> Function() operation) {
    final result = _queue.then((_) => operation());
    _queue = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<bool> reconcile(List<Task> tasks, AppSettings settings) =>
      _serialize(() async {
        final allowed =
            settings.isNotificationEnabled && await platform.permission();
        final desired = allowed
            ? planNotifications(tasks, settings, clock())
            : <NotificationRequest>[];
        final pending = await platform.pending();
        final ids = desired.map((r) => r.id).toSet();
        for (final id in pending.keys) {
          if ((id > 0 && !ids.contains(id)) || (!allowed && id < 0)) {
            await platform.cancel(id);
          }
        }
        for (final request in desired) {
          if (pending[request.id] != request.fingerprint) {
            await platform.schedule(request);
          }
        }
        return allowed;
      });

  /// Absolute end-time API for the future focus timer; replacing the same ID
  /// updates its end time and cancellation must be called on pause/stop.
  // TODO(JANUS-60): Focuspage is a Placeholder; connect these APIs when a real
  // focus session model/timer exists rather than inventing a second timer UI.
  Future<bool> scheduleCountdown(DateTime endsAt, AppSettings settings) =>
      _serialize(() async {
        await platform.cancel(-1);
        if (!settings.isNotificationEnabled ||
            !endsAt.isAfter(clock()) ||
            !await platform.permission()) {
          return false;
        }
        await platform.schedule(
          NotificationRequest(
            -1,
            '倒计时结束',
            endsAt,
            settings.urgentNotificationStyle.name,
          ),
        );
        return true;
      });

  Future<void> cancelCountdown() => _serialize(() => platform.cancel(-1));
}
