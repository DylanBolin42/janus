import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/models/app_settings.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // Enum display labels
  // ─────────────────────────────────────────────────────────────────────────
  group('AppThemeMode labels & conversion', () {
    test('labels are in Chinese', () {
      expect(AppThemeMode.system.label, '跟随系统');
      expect(AppThemeMode.light.label, '明亮模式');
      expect(AppThemeMode.dark.label, '暗黑模式');
    });

    test('toFlutter maps correctly', () {
      expect(AppThemeMode.system.toFlutter(), ThemeMode.system);
      expect(AppThemeMode.light.toFlutter(), ThemeMode.light);
      expect(AppThemeMode.dark.toFlutter(), ThemeMode.dark);
    });

    test('fromFlutter round-trips correctly', () {
      for (final mode in ThemeMode.values) {
        expect(
          AppThemeModeX.fromFlutter(mode).toFlutter(),
          mode,
        );
      }
    });
  });

  group('GlassIntensity labels', () {
    test('labels are in Chinese', () {
      expect(GlassIntensity.extreme.label, '极致');
      expect(GlassIntensity.moderate.label, '适中');
      expect(GlassIntensity.low.label, '低');
    });
  });

  group('AppLanguage labels', () {
    test('labels match expected display names', () {
      expect(AppLanguage.chinese.label, '中文');
      expect(AppLanguage.english.label, 'English');
    });
  });

  group('TabNamingStyle labels', () {
    test('labels are in Chinese', () {
      expect(TabNamingStyle.classic.label, '经典');
      expect(TabNamingStyle.latin.label, '拉丁');
      expect(TabNamingStyle.professional.label, '专业');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // AppSettings model
  // ─────────────────────────────────────────────────────────────────────────
  group('AppSettings defaults', () {
    test('default values', () {
      const settings = AppSettings();

      expect(settings.themeMode, AppThemeMode.system);
      expect(settings.glassIntensity, GlassIntensity.moderate);
      expect(settings.language, AppLanguage.chinese);
      expect(settings.tabNamingStyle, TabNamingStyle.classic);
    });
  });

  group('AppSettings copyWith', () {
    test('copyWith overrides a single field', () {
      const original = AppSettings();
      final modified = original.copyWith(themeMode: AppThemeMode.dark);

      expect(modified.themeMode, AppThemeMode.dark);
      // Other fields unchanged
      expect(modified.glassIntensity, original.glassIntensity);
      expect(modified.language, original.language);
      expect(modified.tabNamingStyle, original.tabNamingStyle);
    });

    test('copyWith on a non-default instance', () {
      const original = AppSettings(
        themeMode: AppThemeMode.dark,
        glassIntensity: GlassIntensity.low,
        language: AppLanguage.english,
        tabNamingStyle: TabNamingStyle.professional,
      );
      final modified = original.copyWith(language: AppLanguage.chinese);

      expect(modified.language, AppLanguage.chinese);
      expect(modified.themeMode, AppThemeMode.dark); // unchanged
      expect(modified.glassIntensity, GlassIntensity.low); // unchanged
      expect(modified.tabNamingStyle, TabNamingStyle.professional); // unchanged
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // JSON serialization
  // ─────────────────────────────────────────────────────────────────────────
  group('AppSettings JSON serialization', () {
    test('serializes to JSON and deserializes back', () {
      const original = AppSettings(
        themeMode: AppThemeMode.dark,
        glassIntensity: GlassIntensity.extreme,
        language: AppLanguage.english,
        tabNamingStyle: TabNamingStyle.latin,
      );

      final json = original.toJson();
      final restored = AppSettings.fromJson(json);

      expect(restored, original);
    });

    test('missing field falls back to default', () {
      final restored = AppSettings.fromJson(<String, dynamic>{});

      expect(restored.themeMode, AppThemeMode.system);
      expect(restored.glassIntensity, GlassIntensity.moderate);
      expect(restored.language, AppLanguage.chinese);
      expect(restored.tabNamingStyle, TabNamingStyle.classic);
    });

    test('partial JSON uses defaults for missing keys', () {
      final restored = AppSettings.fromJson({
        'themeMode': 'light',
      });

      expect(restored.themeMode, AppThemeMode.light);
      expect(restored.glassIntensity, GlassIntensity.moderate); // default
      expect(restored.language, AppLanguage.chinese); // default
      expect(restored.tabNamingStyle, TabNamingStyle.classic); // default
    });

    test('handles all enum values in round-trip', () {
      for (final theme in AppThemeMode.values) {
        for (final glass in GlassIntensity.values) {
          for (final lang in AppLanguage.values) {
            for (final tab in TabNamingStyle.values) {
              final original = AppSettings(
                themeMode: theme,
                glassIntensity: glass,
                language: lang,
                tabNamingStyle: tab,
              );
              expect(AppSettings.fromJson(original.toJson()), original);
            }
          }
        }
      }
    });

    test('equality works', () {
      const a = AppSettings(themeMode: AppThemeMode.dark);
      const b = AppSettings(themeMode: AppThemeMode.dark);
      const c = AppSettings(themeMode: AppThemeMode.light);

      expect(a, b);
      expect(a, isNot(c));
    });
  });
}
