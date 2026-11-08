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
  @override
  Future<bool> permission({bool request = false}) async => allowed;
  @override
  Future<Map<int, String?>> pending() async => {
    for (final r in requests.values) r.id: r.fingerprint,
  };
  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    requests.remove(id);
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
    expect(plan.first.id, 2);
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
      expect(platform.requests[-1]?.at, end);
      await service.reconcile([task()], enabled);
      expect(platform.requests.containsKey(-1), true);
      await service.scheduleCountdown(
        end.add(const Duration(minutes: 5)),
        enabled,
      );
      expect(platform.requests[-1]?.at, end.add(const Duration(minutes: 5)));
      await service.cancelCountdown();
      expect(platform.requests.containsKey(-1), false);
      expect(await service.scheduleCountdown(now, enabled), false);
      expect(await service.scheduleCountdown(end, const AppSettings()), false);
      platform.allowed = false;
      expect(await service.scheduleCountdown(end, enabled), false);
    },
  );
}
