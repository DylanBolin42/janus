import 'package:flutter_test/flutter_test.dart';
import 'package:janus/theme/theme.dart';

void main() {
  group('AppSpacing', () {
    test('constants have correct values', () {
      expect(AppSpacing.base, 8.0);
      expect(AppSpacing.containerMax, 1280.0);
      expect(AppSpacing.containerPadding, 32.0);
      expect(AppSpacing.gutter, 24.0);
      expect(AppSpacing.marginDesktop, 64.0);
      expect(AppSpacing.marginMobile, 16.0);
      expect(AppSpacing.topSafeArea, 120.0);
      expect(AppSpacing.bottomSafeArea, 60.0);
    });
  });

  group('AppRadius', () {
    test('constants have correct values', () {
      expect(AppRadius.sm, 8.0);
      expect(AppRadius.def, 16.0);
      expect(AppRadius.md, 24.0);
      expect(AppRadius.lg, 32.0);
      expect(AppRadius.xl, 48.0);
      expect(AppRadius.full, 9999.0);
    });
  });

  group('FontFamily', () {
    test('constants are non-empty strings', () {
      expect(FontFamily.serif, isNotEmpty);
      expect(FontFamily.chineseSerif, isNotEmpty);
      expect(FontFamily.sans, isNotEmpty);
    });

    test('serif font family', () {
      expect(FontFamily.serif, 'EnglishLiterature');
    });

    test('chinese serif font family', () {
      expect(FontFamily.chineseSerif, 'ChineseLiterature');
    });

    test('sans font family', () {
      expect(FontFamily.sans, 'GoogleSans');
    });
  });
}
