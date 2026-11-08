import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/services/local_notification_platform.dart';
import 'package:janus/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final calls = <MethodCall>[];
  bool exact = false;
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    calls.clear();
    exact = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          switch (call.method) {
            case 'initialize':
              return true;
            case 'areNotificationsEnabled':
              return false;
            case 'requestNotificationsPermission':
              return false;
            case 'canScheduleExactNotifications':
              return exact;
            case 'checkPermissions':
              return {'isAlertEnabled': true};
            case 'requestPermissions':
              return false;
            case 'pendingNotificationRequests':
              return <dynamic>[];
            default:
              return null;
          }
        });
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'adapter checks permission without prompting; denial is false',
    () async {
      final platform = LocalNotificationPlatform();
      expect(await platform.permission(), false);
      expect(calls.map((c) => c.method), [
        'initialize',
        'areNotificationsEnabled',
      ]);
      expect(await platform.permission(request: true), false);
      expect(calls.last.method, 'requestNotificationsPermission');
      expect(calls.where((c) => c.method == 'initialize'), hasLength(1));
    },
  );

  test(
    'adapter schedules UTC instant with inexact fallback, styles and persisted fingerprint',
    () async {
      final platform = LocalNotificationPlatform();
      final request = NotificationRequest(
        NotificationIds.task(1),
        '有任务即将到期',
        DateTime.now().add(const Duration(days: 2)),
        'notifierAndRing',
      );
      await platform.schedule(request);
      var args = calls.last.arguments as Map;
      expect(calls.last.method, 'zonedSchedule');
      expect(args['timeZoneName'], 'Etc/UTC');
      expect(args['payload'], request.fingerprint);
      expect(
        (args['platformSpecifics'] as Map)['scheduleMode'],
        'inexactAllowWhileIdle',
      );
      expect((args['platformSpecifics'] as Map)['playSound'], true);
      expect(
        (args['platformSpecifics'] as Map)['visibility'],
        NotificationVisibility.private.index,
      );
      exact = true;
      await platform.schedule(request);
      args = calls.last.arguments as Map;
      expect(
        (args['platformSpecifics'] as Map)['scheduleMode'],
        'exactAllowWhileIdle',
      );
      await platform.cancel(NotificationIds.task(1));
      expect(calls.last.method, 'cancel');
    },
  );

  test(
    'iOS checks alert authorization and schedules a foreground banner',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      IOSFlutterLocalNotificationsPlugin.registerWith();
      final platform = LocalNotificationPlatform();
      expect(await platform.permission(), true);
      expect(await platform.permission(request: true), false);
      await platform.schedule(
        NotificationRequest(
          NotificationIds.countdown,
          'Countdown',
          DateTime.now().add(const Duration(hours: 1)),
          'notifierAndRing',
        ),
      );
      final args = calls.last.arguments as Map;
      expect(calls.last.method, 'zonedSchedule');
      expect((args['platformSpecifics'] as Map)['presentBanner'], true);
      expect((args['platformSpecifics'] as Map)['presentSound'], true);
    },
  );

  test('unsupported desktop never reports enabled or scheduled', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    final platform = LocalNotificationPlatform();
    expect(await platform.permission(request: true), false);
    expect(await platform.pending(), isEmpty);
    await expectLater(
      platform.schedule(
        NotificationRequest(2, 'Task', DateTime.now(), 'notifier'),
      ),
      throwsUnsupportedError,
    );
    expect(calls, isEmpty);
  });
}
