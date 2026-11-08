import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/services/local_notification_platform.dart';
import 'package:janus/services/notification_service.dart';
import 'database_provider.dart';
import 'settings_provider.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(LocalNotificationPlatform()),
);

final notificationTasksProvider = StreamProvider(
  (ref) => ref.watch(taskDaoProvider).watchAllTasks(),
);

/// Watched by the app root: DB and settings changes automatically reconcile.
final notificationSyncProvider = FutureProvider<bool>((ref) async {
  final settings = await ref.watch(appSettingsProvider.future);
  final tasks = await ref.watch(notificationTasksProvider.future);
  return ref.read(notificationServiceProvider).reconcile(tasks, settings);
});
