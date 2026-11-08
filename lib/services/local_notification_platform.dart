import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'notification_service.dart';

class LocalNotificationPlatform implements NotificationPlatform {
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _initialization;
  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _initialize() => _initialization ??= _initializePlugin().onError(
    (Object error, StackTrace stack) {
      _initialization = null;
      Error.throwWithStackTrace(error, stack);
    },
  );
  Future<void> _initializePlugin() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  @override
  Future<bool> permission({bool request = false}) async {
    if (!supported) return false;
    await _initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return (request
              ? await android.requestNotificationsPermission()
              : await android.areNotificationsEnabled()) ??
          false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (request) {
      return await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return (await ios?.checkPermissions())?.isAlertEnabled ?? false;
  }

  @override
  Future<Map<int, String?>> pending() async {
    if (!supported) return {};
    await _initialize();
    return {
      for (final r in await _plugin.pendingNotificationRequests())
        r.id: r.payload,
    };
  }

  @override
  Future<void> cancel(int id) async {
    if (!supported) return;
    await _initialize();
    await _plugin.cancel(id: id);
  }

  @override
  Future<void> schedule(NotificationRequest request) async {
    if (!supported) {
      throw UnsupportedError('Local notifications require Android/iOS');
    }
    await _initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final exact = await android?.canScheduleExactNotifications() ?? false;
    final ring = request.style == 'notifierAndRing';
    final vibrate = request.style == 'notifierAndShake';
    // TODO(JANUS-60): Full-screen intents require special OS approval and a
    // qualifying use case. Fall back to a banner; never claim full-screen works.
    await _plugin.zonedSchedule(
      id: request.id,
      title: request.title,
      scheduledDate: tz.TZDateTime.from(request.at, tz.UTC),
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'janus_${request.style}',
          '任务提醒 (${request.style})',
          importance: Importance.high,
          priority: Priority.high,
          visibility: NotificationVisibility.private,
          playSound: ring,
          enableVibration: vibrate,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBanner: true,
          presentSound: ring,
        ),
      ),
      payload: request.fingerprint,
    );
  }

  // TODO(JANUS-60): iOS ActivityKit needs a signed Widget Extension, entitlements
  // and a native session bridge; Android needs an ongoing focus notification
  // bound to that session's lifecycle. No focus/live-activity success is exposed
  // until those implementations and device lifecycle tests exist.
}
