import 'dart:convert';

import 'package:janus/database/app_database.dart';
import 'package:janus/models/app_settings.dart';

/// Reserved Janus notification IDs (signed 32-bit on Android):
/// 0x4A000002..0x4AFFFFFF: two slots per task, DB IDs 1..0x7FFFFF.
/// 0x4B000001: the single countdown; 0x4B000000..0x4B0000FF is reserved
/// for future focus notifications. Other notification producers must avoid
/// these ranges. Payload ownership is also checked before replacing/cancelling.
abstract final class NotificationIds {
  static const taskBase = 0x4A000000;
  static const maxTaskId = 0x7FFFFF;
  static const countdown = 0x4B000001;
  static const payloadNamespace = 'janus.notifications.v2';

  static int task(int id, {bool urgent = false}) {
    RangeError.checkValueInInterval(id, 1, maxTaskId, 'taskId');
    return taskBase + id * 2 + (urgent ? 1 : 0);
  }

  static bool isTask(int id) => id >= taskBase + 2 && id <= taskBase + 0xFFFFFF;

  static bool _hasPayload(int id, String? payload, String namespace) {
    if (payload == null) return false;
    try {
      final decoded = jsonDecode(payload);
      return decoded is List &&
          decoded.length == 5 &&
          decoded[0] == namespace &&
          decoded[1] == id;
    } on FormatException {
      return false;
    }
  }

  static bool owns(int id, String? payload) =>
      (isTask(id) || id == countdown) &&
      _hasPayload(id, payload, payloadNamespace);

  /// Migrate only requests bearing our old payload marker, never arbitrary
  /// positive/negative IDs belonging to another notification producer.
  static bool isLegacy(int id, String? payload) =>
      _hasPayload(id, payload, 'janus.task');
}

/// An absolute instant: schedules remain correct across timezone/DST changes.
class NotificationRequest {
  const NotificationRequest(this.id, this.title, this.at, this.style);
  final int id;
  final String title;
  final DateTime at;
  final String style;
  String get fingerprint => jsonEncode([
    NotificationIds.payloadNamespace,
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
  DateTime now, {
  bool showTaskTitles = false,
}) {
  if (!settings.isNotificationEnabled) return [];
  final result = <NotificationRequest>[];
  for (final task in tasks) {
    if (task.status != 0 && task.status != 2) continue;
    if (task.id <= 0 || task.id > NotificationIds.maxTaskId) continue;
    for (final urgent in [false, true]) {
      final at = task.ddl.subtract(Duration(hours: urgent ? 6 : 24));
      if (!at.isAfter(now)) continue;
      result.add(
        NotificationRequest(
          NotificationIds.task(task.id, urgent: urgent),
          showTaskTitles
              ? '${urgent ? '任务紧迫' : '任务临近'}：${task.title}'
              : '有任务即将到期',
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
  NotificationService(
    this.platform, {
    DateTime Function()? clock,
    this.showTaskTitles = false,
  }) : clock = clock ?? DateTime.now;
  final NotificationPlatform platform;

  /// Privacy default: neither visible content nor payload contains task titles.
  /// Set true only after the caller has obtained explicit user opt-in.
  final bool showTaskTitles;
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
            ? planNotifications(
                tasks,
                settings,
                clock(),
                showTaskTitles: showTaskTitles,
              )
            : <NotificationRequest>[];
        final pending = await platform.pending();
        final ids = desired.map((r) => r.id).toSet();
        for (final id in pending.keys.toList()) {
          final owned = NotificationIds.owns(id, pending[id]);
          if (NotificationIds.isLegacy(id, pending[id]) ||
              (owned &&
                  ((NotificationIds.isTask(id) && !ids.contains(id)) ||
                      !allowed))) {
            await platform.cancel(id);
            pending.remove(id);
          }
        }
        for (final request in desired) {
          if (pending.containsKey(request.id) &&
              !NotificationIds.owns(request.id, pending[request.id])) {
            throw StateError(
              'Notification ID namespace collision: ${request.id}',
            );
          }
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
        await _cancelCountdown();
        if (!settings.isNotificationEnabled ||
            !endsAt.isAfter(clock()) ||
            !await platform.permission()) {
          return false;
        }
        await platform.schedule(
          NotificationRequest(
            NotificationIds.countdown,
            '倒计时结束',
            endsAt,
            settings.urgentNotificationStyle.name,
          ),
        );
        return true;
      });

  Future<void> _cancelCountdown() async {
    final pending = await platform.pending();
    final id = NotificationIds.countdown;
    if (pending.containsKey(id) && !NotificationIds.owns(id, pending[id])) {
      throw StateError('Notification ID namespace collision: $id');
    }
    await platform.cancel(id);
    if (NotificationIds.isLegacy(-1, pending[-1])) {
      await platform.cancel(-1);
    }
  }

  Future<void> cancelCountdown() => _serialize(_cancelCountdown);
}
