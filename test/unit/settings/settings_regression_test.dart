import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/models/app_settings.dart';
import 'package:janus/providers/settings_provider.dart';
import 'package:janus/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ControlledSettingsService extends SettingsService {
  final loaded = Completer<AppSettings>();
  AppSettings? saved;
  bool fail = false;

  @override
  Future<AppSettings> load() => loaded.future;

  @override
  Future<void> save(AppSettings settings) async {
    if (fail) throw StateError('disk full');
    saved = settings;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'startup edits wait for saved values and concurrent edits are merged',
    () async {
      final service = ControlledSettingsService();
      final container = ProviderContainer(
        overrides: [settingsServiceProvider.overrideWithValue(service)],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(appSettingsProvider, (_, _) {});
      addTearDown(subscription.close);
      final notifier = container.read(appSettingsProvider.notifier);
      final themeEdit = notifier.setThemeMode(AppThemeMode.dark);
      final notificationEdit = notifier.setNotificationEnabled(true);
      service.loaded.complete(const AppSettings(language: AppLanguage.english));
      await Future.wait([themeEdit, notificationEdit]);
      expect(service.saved!.themeMode, AppThemeMode.dark);
      expect(service.saved!.isNotificationEnabled, isTrue);
      expect(service.saved!.language, AppLanguage.english);
      expect(container.read(themeModeProvider), ThemeMode.dark);
    },
  );

  test('failed save keeps previous value and next edit can succeed', () async {
    final service = ControlledSettingsService()
      ..loaded.complete(const AppSettings());
    final container = ProviderContainer(
      overrides: [settingsServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(appSettingsProvider, (_, _) {});
    addTearDown(subscription.close);
    await container.read(appSettingsProvider.future);
    final notifier = container.read(appSettingsProvider.notifier);
    service.fail = true;
    await expectLater(
      notifier.setThemeMode(AppThemeMode.dark),
      throwsStateError,
    );
    expect(
      container.read(appSettingsProvider).value!.themeMode,
      AppThemeMode.system,
    );
    service.fail = false;
    await notifier.setLanguage(AppLanguage.english);
    expect(service.saved!.language, AppLanguage.english);
    expect(service.saved!.themeMode, AppThemeMode.system);
  });

  test(
    'briefing and focus defaults, edits and reload use real persistence',
    () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final subscription = container.listen(appSettingsProvider, (_, _) {});
      addTearDown(subscription.close);
      final defaults = await container.read(appSettingsProvider.future);
      expect(defaults.morningBriefingTime, const TimeOfDay(hour: 8, minute: 0));
      expect(
        defaults.eveningBriefingTime,
        const TimeOfDay(hour: 20, minute: 0),
      );
      expect(defaults.focusTimerMode, FocusTimerMode.countdown);
      final notifier = container.read(appSettingsProvider.notifier);
      await Future.wait([
        notifier.setMorningBriefingTime(const TimeOfDay(hour: 9, minute: 30)),
        notifier.setEveningBriefingTime(const TimeOfDay(hour: 22, minute: 15)),
        notifier.setFocusTimerMode(FocusTimerMode.pomodoro),
        notifier.setTabNamingStyle(TabNamingStyle.professional),
      ]);
      final reloaded = await SettingsService().load();
      expect(reloaded, container.read(appSettingsProvider).value);
      expect(
        reloaded.morningBriefingTime,
        const TimeOfDay(hour: 9, minute: 30),
      );
      expect(
        reloaded.eveningBriefingTime,
        const TimeOfDay(hour: 22, minute: 15),
      );
      expect(reloaded.focusTimerMode, FocusTimerMode.pomodoro);
      expect(reloaded.tabNamingStyle.tabLabels.first, '待处理');
      await expectLater(
        notifier.setSyncDurationOnInterval(Duration.zero),
        throwsArgumentError,
      );
      await expectLater(
        notifier.setSyncDurationOnInterval(const Duration(days: 1)),
        throwsArgumentError,
      );
      await notifier.setSyncDurationOnInterval(const Duration(minutes: 1));
      expect(
        (await SettingsService().load()).syncDurationOnInterval,
        const Duration(minutes: 1),
      );
    },
  );

  test('wrong preference type safely falls back to defaults', () async {
    SharedPreferences.setMockInitialValues({'app_settings': 42});
    expect(await SettingsService().load(), const AppSettings());
  });
}
