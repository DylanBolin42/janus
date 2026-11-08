import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:janus/models/app_settings.dart';
import 'package:janus/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SettingsService', () {
    late SettingsService service;

    setUp(() {
      service = SettingsService();
    });

    test('load returns defaults when nothing stored', () async {
      SharedPreferences.setMockInitialValues({});

      final settings = await service.load();

      expect(settings.themeMode, AppThemeMode.system);
      expect(settings.glassIntensity, GlassIntensity.moderate);
      expect(settings.language, AppLanguage.chinese);
      expect(settings.tabNamingStyle, TabNamingStyle.classic);
    });

    test('save and load round-trips correctly', () async {
      SharedPreferences.setMockInitialValues({});

      const expected = AppSettings(
        themeMode: AppThemeMode.dark,
        glassIntensity: GlassIntensity.extreme,
        language: AppLanguage.english,
        tabNamingStyle: TabNamingStyle.professional,
      );

      await service.save(expected);
      final loaded = await service.load();

      expect(loaded, expected);
    });

    test('load recovers from corrupt JSON and returns defaults', () async {
      SharedPreferences.setMockInitialValues({
        'app_settings': '{malformed json!!!}',
      });

      final settings = await service.load();

      expect(settings, const AppSettings());
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString(SettingsService.corruptBackupKey),
        '{malformed json!!!}',
      );
      expect(service.recoveredCorruptSettings, isTrue);
      await service.save(const AppSettings(themeMode: AppThemeMode.dark));
      expect(
        prefs.getString(SettingsService.corruptBackupKey),
        '{malformed json!!!}',
      );
    });

    test(
      'invalid fields are backed up while valid preferences survive',
      () async {
        final raw = jsonEncode({
          'themeMode': 'dark',
          'language': 'invalid-language',
          'isNotificationEnabled': 'yes',
          'morningBriefingTime': '25:99',
        });
        SharedPreferences.setMockInitialValues({'app_settings': raw});
        final settings = await service.load();
        expect(settings.themeMode, AppThemeMode.dark);
        expect(settings.language, AppLanguage.chinese);
        expect(settings.isNotificationEnabled, isFalse);
        expect(settings.morningBriefingTime.hour, 8);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString(SettingsService.corruptBackupKey), raw);
        expect(prefs.getString('app_settings'), raw);
      },
    );

    test('direct save backs up corrupt data before overwriting it', () async {
      SharedPreferences.setMockInitialValues({'app_settings': '[]'});
      await service.save(const AppSettings());
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(SettingsService.corruptBackupKey), '[]');
    });

    test('multiple save/load cycles preserve latest value', () async {
      SharedPreferences.setMockInitialValues({});

      const first = AppSettings(themeMode: AppThemeMode.light);
      const second = AppSettings(themeMode: AppThemeMode.dark);

      await service.save(first);
      await service.save(second);
      final loaded = await service.load();

      expect(loaded.themeMode, AppThemeMode.dark);
    });

    test('stored JSON has the correct key and format', () async {
      SharedPreferences.setMockInitialValues({});

      const settings = AppSettings(themeMode: AppThemeMode.dark);
      await service.save(settings);

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('app_settings');

      expect(raw, isNotNull);
      final decoded = jsonDecode(raw!) as Map<String, dynamic>;
      expect(decoded['themeMode'], 'dark');
      expect(decoded['glassIntensity'], 'moderate');

      final restored = AppSettings.fromJson(decoded);
      expect(restored, settings);
    });
  });
}
