import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/theme/theme.dart';

void main() {
  group('AppTheme', () {
    test('light theme is not null', () {
      expect(AppTheme.light, isNotNull);
    });

    test('dark theme is not null', () {
      expect(AppTheme.dark, isNotNull);
    });

    test('light theme has correct brightness', () {
      expect(AppTheme.light.brightness, Brightness.light);
    });

    test('dark theme has correct brightness', () {
      expect(AppTheme.dark.brightness, Brightness.dark);
    });

    test('light color scheme primary color', () {
      expect(
        AppTheme.light.colorScheme.primary,
        const Color(0xFFB72301),
      );
    });

    test('dark color scheme primary color', () {
      expect(
        AppTheme.dark.colorScheme.primary,
        const Color(0xFFFFB68E),
      );
    });

    test('forBrightness returns light theme for light', () {
      expect(
        AppTheme.forBrightness(Brightness.light),
        same(AppTheme.light),
      );
    });

    test('forBrightness returns dark theme for dark', () {
      expect(
        AppTheme.forBrightness(Brightness.dark),
        same(AppTheme.dark),
      );
    });

    test('light theme uses Material3', () {
      expect(AppTheme.light.useMaterial3, isTrue);
    });

    test('dark theme uses Material3', () {
      expect(AppTheme.dark.useMaterial3, isTrue);
    });
  });

  group('TextTheme', () {
    test('light text theme has all text styles', () {
      final textTheme = AppTheme.light.textTheme;
      expect(textTheme.displayLarge, isNotNull);
      expect(textTheme.headlineLarge, isNotNull);
      expect(textTheme.headlineMedium, isNotNull);
      expect(textTheme.headlineSmall, isNotNull);
      expect(textTheme.titleMedium, isNotNull);
      expect(textTheme.bodyLarge, isNotNull);
      expect(textTheme.bodyMedium, isNotNull);
      expect(textTheme.labelLarge, isNotNull);
      expect(textTheme.labelSmall, isNotNull);
    });

    test('dark text theme has all text styles', () {
      final textTheme = AppTheme.dark.textTheme;
      expect(textTheme.displayLarge, isNotNull);
      expect(textTheme.headlineLarge, isNotNull);
      expect(textTheme.headlineMedium, isNotNull);
      expect(textTheme.headlineSmall, isNotNull);
      expect(textTheme.titleMedium, isNotNull);
      expect(textTheme.bodyLarge, isNotNull);
      expect(textTheme.bodyMedium, isNotNull);
      expect(textTheme.labelLarge, isNotNull);
      expect(textTheme.labelSmall, isNotNull);
    });
  });

  group('Component themes', () {
    test('light theme has filled button theme', () {
      expect(AppTheme.light.filledButtonTheme, isNotNull);
    });

    test('light theme has outlined button theme', () {
      expect(AppTheme.light.outlinedButtonTheme, isNotNull);
    });

    test('light theme has input decoration theme', () {
      expect(AppTheme.light.inputDecorationTheme, isNotNull);
    });

    test('light theme has card theme', () {
      expect(AppTheme.light.cardTheme, isNotNull);
    });

    test('light theme has chip theme', () {
      expect(AppTheme.light.chipTheme, isNotNull);
    });

    test('light theme has list tile theme', () {
      expect(AppTheme.light.listTileTheme, isNotNull);
    });

    test('dark theme has filled button theme', () {
      expect(AppTheme.dark.filledButtonTheme, isNotNull);
    });

    test('dark theme has outlined button theme', () {
      expect(AppTheme.dark.outlinedButtonTheme, isNotNull);
    });

    test('dark theme has input decoration theme', () {
      expect(AppTheme.dark.inputDecorationTheme, isNotNull);
    });

    test('dark theme has card theme', () {
      expect(AppTheme.dark.cardTheme, isNotNull);
    });

    test('dark theme has chip theme', () {
      expect(AppTheme.dark.chipTheme, isNotNull);
    });

    test('dark theme has list tile theme', () {
      expect(AppTheme.dark.listTileTheme, isNotNull);
    });
  });

  group('Color tokens (typedef-accessible)', () {
    test('DarkColors has expected primary', () {
      expect(DarkColors.primary, const Color(0xFFFFB68E));
    });

    test('LightColors has expected primary', () {
      expect(LightColors.primary, const Color(0xFFB72301));
    });

    test('DarkColors surface is dark', () {
      expect(DarkColors.surface, const Color(0xFF111415));
    });

    test('LightColors surface is light', () {
      expect(LightColors.surface, const Color(0xFFFBF9F4));
    });
  });
}
