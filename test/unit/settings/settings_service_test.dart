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

    test('saveApiKey obfuscates and stores API Key, loadApiKey deciphers it correctly', () async {
      SharedPreferences.setMockInitialValues({});

      const rawApiKey = 'my_secret_ai_api_key_12345';
      await service.saveApiKey(rawApiKey);

      // Verify it is NOT stored in plain text
      final prefs = await SharedPreferences.getInstance();
      final rawStored = prefs.getString('ai_api_key');
      expect(rawStored, isNotNull);
      expect(rawStored, isNot(rawApiKey));

      // Verify loading retrieves the plain text correctly
      final loadedKey = await service.loadApiKey();
      expect(loadedKey, rawApiKey);
    });

    test('saveApiKey with empty key removes it from preferences', () async {
      SharedPreferences.setMockInitialValues({});

      await service.saveApiKey('some_key');
      await service.saveApiKey('');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('ai_api_key'), false);

      final loadedKey = await service.loadApiKey();
      expect(loadedKey, '');
    });
  });
}
