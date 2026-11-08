import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/database/app_database.dart';
import 'package:janus/providers/notification_provider.dart';
import 'package:janus/providers/settings_provider.dart';
import 'package:janus/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service_test.dart' show FakePlatform;

void main() {
  test(
    'task stream and persisted settings trigger app reconciliation',
    () async {
      SharedPreferences.setMockInitialValues({});
      final tasks = StreamController<List<Task>>();
      final platform = FakePlatform();
      final now = DateTime.utc(2026, 11, 8);
      final container = ProviderContainer(
        overrides: [
          notificationTasksProvider.overrideWith((ref) => tasks.stream),
          notificationServiceProvider.overrideWithValue(
            NotificationService(platform, clock: () => now),
          ),
        ],
      );
      final subscription = container.listen(
        notificationSyncProvider,
        (_, _) {},
      );
      addTearDown(() async {
        subscription.close();
        container.dispose();
        await tasks.close();
      });
      tasks.add([
        Task(
          id: 1,
          title: 'Task',
          ddl: now.add(const Duration(days: 2)),
          status: 0,
          priority: 0,
        ),
      ]);
      expect(await container.read(notificationSyncProvider.future), false);
      await container
          .read(appSettingsProvider.notifier)
          .setNotificationEnabled(true);
      await container.read(notificationSyncProvider.future);
      expect(platform.requests, hasLength(2));
      tasks.add([]);
      // Let StreamProvider publish the next snapshot before reading its future.
      await Future<void>.delayed(Duration.zero);
      await container.read(notificationSyncProvider.future);
      expect(platform.requests, isEmpty);
      await container
          .read(appSettingsProvider.notifier)
          .setNotificationEnabled(false);
      expect(await container.read(notificationSyncProvider.future), false);
    },
  );
}
