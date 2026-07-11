import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/models/app_settings.dart';
import 'package:janus/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ─────────────────────────────────────────────────────────────────────────
  // settingsServiceProvider
  // ─────────────────────────────────────────────────────────────────────────
  group('settingsServiceProvider', () {
    test('provides a non-null SettingsService', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final service = container.read(settingsServiceProvider);

      expect(service, isNotNull);
    });

    test('is a singleton within the same container', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final a = container.read(settingsServiceProvider);
      final b = container.read(settingsServiceProvider);

      expect(a, same(b));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // appSettingsNotifierProvider
  // ─────────────────────────────────────────────────────────────────────────
  group('appSettingsNotifierProvider', () {
    /// Helper: wait for the notifier's async build to complete.
    Future<void> waitForInit(ProviderContainer container) async {
      await container.read(appSettingsNotifierProvider.notifier).future;
    }

    test('loads default settings initially', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      expect(container.read(appSettingsNotifierProvider).isLoading, true);

      await waitForInit(container);

      final settings = container.read(appSettingsNotifierProvider);
      expect(settings.hasValue, true);
      expect(settings.valueOrNull!.themeMode, AppThemeMode.system);
    });

    test('setThemeMode updates the value and persists', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      await waitForInit(container);

      await container
          .read(appSettingsNotifierProvider.notifier)
          .setThemeMode(AppThemeMode.dark);

      expect(
        container.read(appSettingsNotifierProvider).valueOrNull!.themeMode,
        AppThemeMode.dark,
      );
    });

    test('setGlassIntensity updates the value', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      await waitForInit(container);

      await container
          .read(appSettingsNotifierProvider.notifier)
          .setGlassIntensity(GlassIntensity.extreme);

      expect(
        container.read(appSettingsNotifierProvider).valueOrNull!.glassIntensity,
        GlassIntensity.extreme,
      );
    });

    test('setLanguage updates the value', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      await waitForInit(container);

      await container
          .read(appSettingsNotifierProvider.notifier)
          .setLanguage(AppLanguage.english);

      expect(
        container.read(appSettingsNotifierProvider).valueOrNull!.language,
        AppLanguage.english,
      );
    });

    test('setTabNamingStyle updates the value', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      await waitForInit(container);

      await container
          .read(appSettingsNotifierProvider.notifier)
          .setTabNamingStyle(TabNamingStyle.professional);

      expect(
        container.read(appSettingsNotifierProvider).valueOrNull!.tabNamingStyle,
        TabNamingStyle.professional,
      );
    });

    test('multiple mutations persist independently', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      await waitForInit(container);

      final notifier = container.read(appSettingsNotifierProvider.notifier);

      await notifier.setThemeMode(AppThemeMode.dark);
      await notifier.setLanguage(AppLanguage.english);
      await notifier.setTabNamingStyle(TabNamingStyle.latin);

      final settings = container.read(appSettingsNotifierProvider).valueOrNull!;
      expect(settings.themeMode, AppThemeMode.dark);
      expect(settings.language, AppLanguage.english);
      expect(settings.tabNamingStyle, TabNamingStyle.latin);
      expect(settings.glassIntensity, GlassIntensity.moderate); // ← unchanged
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // themeModeProvider
  // ─────────────────────────────────────────────────────────────────────────
  group('themeModeProvider', () {
    Future<void> waitForInit(ProviderContainer container) async {
      await container.read(appSettingsNotifierProvider.notifier).future;
    }

    test('defaults to ThemeMode.system', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      await waitForInit(container);

      expect(container.read(themeModeProvider), ThemeMode.system);
    });

    test('changes when AppSettingsNotifier updates theme', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      await waitForInit(container);

      await container
          .read(appSettingsNotifierProvider.notifier)
          .setThemeMode(AppThemeMode.light);

      expect(container.read(themeModeProvider), ThemeMode.light);
    });
  });
}
