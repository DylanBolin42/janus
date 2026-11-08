import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/database/app_database.dart';
import 'package:janus/models/app_settings.dart';
import 'package:janus/services/notification_service.dart';

class FakePlatform implements NotificationPlatform {
  bool allowed = true;
  bool fail = false;
  final requests = <int, NotificationRequest>{};
  final cancelled = <int>[];
  int writes = 0;
  final foreign = <int, String?>{};
  @override
  Future<bool> permission({bool request = false}) async => allowed;
  @override
  Future<Map<int, String?>> pending() async => {
    ...foreign,
    for (final r in requests.values) r.id: r.fingerprint,
  };
  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    requests.remove(id);
    foreign.remove(id);
  }

  @override
  Future<void> schedule(NotificationRequest request) async {
    if (fail) throw StateError('OS rejected alarm');
    writes++;
    requests[request.id] = request;
  }
}

void main() {
  final now = DateTime.utc(2026, 11, 8, 12);
  const enabled = AppSettings(isNotificationEnabled: true);
  Task task({int id = 1, int status = 0, int hours = 30}) => Task(
    id: id,
    status: status,
    title: 'Test',
    ddl: now.add(Duration(hours: hours)),
    priority: 0,
  );

  test('DDL schedules at 24h and 6h, with stored styles', () {
    final plan = planNotifications(
      [task()],
      enabled.copyWith(
        approachingNotificationStyle:
            ApproachingNotificationStyle.notifierAndRing,
      ),
      now,
    );
    expect(plan.map((r) => r.at), [
      now.add(const Duration(hours: 6)),
      now.add(const Duration(hours: 24)),
    ]);
    expect(plan.first.style, 'notifierAndRing');
    expect(plan.map((r) => r.id).toSet().length, 2);
  });

  test(
    'private by default; task titles require explicit constructor opt-in',
    () async {
      final privatePlan = planNotifications([task()], enabled, now);
      expect(privatePlan.every((r) => r.title == '有任务即将到期'), true);
      expect(privatePlan.any((r) => r.fingerprint.contains('Test')), false);
      final platform = FakePlatform();
      final withTitles = NotificationService(
        platform,
        clock: () => now,
        showTaskTitles: true,
      );
      await withTitles.reconcile([task()], enabled);
      expect(
        platform.requests.values.every((r) => r.title.contains('Test')),
        true,
      );
      final privateService = NotificationService(platform, clock: () => now);
      await privateService.reconcile([task()], enabled);
      expect(platform.writes, 4);
      expect(
        platform.requests.values.any((r) => r.fingerprint.contains('Test')),
        false,
      );
    },
  );

  test(
    'namespace has distinct bounded task slots and reserved countdown ID',
    () {
      expect(NotificationIds.task(1), 0x4A000002);
      expect(
        NotificationIds.task(NotificationIds.maxTaskId, urgent: true),
        0x4AFFFFFF,
      );
      expect(NotificationIds.countdown, 0x4B000001);
      expect(NotificationIds.isTask(NotificationIds.countdown), false);
      expect(() => NotificationIds.task(0), throwsRangeError);
      expect(
        () => NotificationIds.task(NotificationIds.maxTaskId + 1),
        throwsRangeError,
      );
      expect(
        planNotifications(
          [task(id: NotificationIds.maxTaskId + 1)],
          enabled,
          now,
        ),
        isEmpty,
      );
    },
  );

  test(
    'reconcile only cancels owned payloads and migrates old schedules',
    () async {
      final platform = FakePlatform();
      final legacy = jsonEncode([
        'janus.task',
        2,
        'Old sensitive title',
        now.toIso8601String(),
        'notifier',
      ]);
      platform.foreign.addAll({
        2: legacy,
        7: 'other.plugin',
        -1: null,
        NotificationIds.task(99): 'other.plugin',
      });
      final service = NotificationService(platform, clock: () => now);
      await service.reconcile([task()], enabled);
      expect(platform.cancelled, contains(2));
      expect(
        platform.foreign.keys,
        containsAll([7, -1, NotificationIds.task(99)]),
      );
      await service.reconcile([], const AppSettings());
      expect(platform.requests, isEmpty);
      expect(platform.foreign, hasLength(3));
    },
  );

  test(
    'a foreign producer in our reserved slot is never overwritten or cancelled',
    () async {
      final platform = FakePlatform();
      platform.foreign[NotificationIds.task(1)] = 'other.plugin';
      final service = NotificationService(platform, clock: () => now);
      await expectLater(service.reconcile([task()], enabled), throwsStateError);
      expect(platform.writes, 0);
      expect(platform.cancelled, isEmpty);
      platform.foreign[NotificationIds.countdown] = 'other.plugin';
      await expectLater(
        service.scheduleCountdown(now.add(const Duration(minutes: 5)), enabled),
        throwsStateError,
      );
      expect(platform.cancelled, isEmpty);
    },
  );

  test('no past, boundary, completed, frozen or disabled reminders', () {
    expect(
      planNotifications(
        [task(status: 1), task(status: -1), task(hours: -1), task(hours: 6)],
        enabled,
        now,
      ),
      isEmpty,
    );
    expect(planNotifications([task()], const AppSettings(), now), isEmpty);
    expect(
      planNotifications([task(status: 2, hours: 24)], enabled, now),
      hasLength(1),
    );
  });

  test('nearest 60 requests win deterministically within OS limits', () {
    final plan = planNotifications(
      List.generate(100, (i) => task(id: i + 1, hours: 30 + i)),
      enabled,
      now,
    );
    expect(plan, hasLength(60));
    expect(plan.first.id, NotificationIds.task(1));
    expect(plan.last.at.isBefore(plan.first.at), false);
  });

  test(
    'deduplicate across service restart; edit/status/delete/settings cancel and replace',
    () async {
      final platform = FakePlatform();
      var service = NotificationService(platform, clock: () => now);
      await service.reconcile([task()], enabled);
      expect(platform.writes, 2);
      service = NotificationService(platform, clock: () => now);
      await service.reconcile([task()], enabled);
      expect(platform.writes, 2);
      await service.reconcile([task(hours: 40)], enabled);
      expect(platform.writes, 4);
      await service.reconcile(
        [task(hours: 40)],
        enabled.copyWith(
          urgentNotificationStyle: UrgentNotificationStyle.notifierAndShake,
        ),
      );
      expect(platform.writes, 5);
      await service.reconcile([task(status: 1)], enabled);
      expect(platform.requests, isEmpty);
      await service.reconcile([task()], enabled);
      await service.reconcile([], enabled);
      expect(platform.requests, isEmpty);
      await service.reconcile([task()], enabled);
      await service.reconcile([task()], const AppSettings());
      expect(platform.requests, isEmpty);
    },
  );

  test(
    'permission denial cancels pending tasks and never reports enabled',
    () async {
      final platform = FakePlatform();
      final service = NotificationService(platform, clock: () => now);
      await service.reconcile([task()], enabled);
      platform.allowed = false;
      expect(await service.reconcile([task()], enabled), false);
      expect(platform.requests, isEmpty);
    },
  );

  test(
    'queue recovers after platform failure and latest snapshot wins',
    () async {
      final platform = FakePlatform()..fail = true;
      final service = NotificationService(platform, clock: () => now);
      await expectLater(service.reconcile([task()], enabled), throwsStateError);
      platform.fail = false;
      await Future.wait([
        service.reconcile([task()], enabled),
        service.reconcile([], enabled),
      ]);
      expect(platform.requests, isEmpty);
    },
  );

  test(
    'countdown absolute end, replacement, cancellation, denied/past/disabled',
    () async {
      final platform = FakePlatform();
      final service = NotificationService(platform, clock: () => now);
      final end = now.add(const Duration(minutes: 25));
      expect(await service.scheduleCountdown(end, enabled), true);
      expect(platform.requests[NotificationIds.countdown]?.at, end);
      await service.reconcile([task()], enabled);
      expect(platform.requests.containsKey(NotificationIds.countdown), true);
      await service.scheduleCountdown(
        end.add(const Duration(minutes: 5)),
        enabled,
      );
      expect(
        platform.requests[NotificationIds.countdown]?.at,
        end.add(const Duration(minutes: 5)),
      );
      await service.cancelCountdown();
      expect(platform.requests.containsKey(NotificationIds.countdown), false);
      expect(await service.scheduleCountdown(now, enabled), false);
      expect(await service.scheduleCountdown(end, const AppSettings()), false);
      platform.allowed = false;
      expect(await service.scheduleCountdown(end, enabled), false);
    },
  );
}
