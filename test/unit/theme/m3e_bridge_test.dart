import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/theme/m3e_bridge.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

void main() {
  group('M3E Bridge', () {
    test(
      'buildM3EThemeData builds M3EThemeData matching Flutter ThemeData',
      () {
        final theme = ThemeData.light();
        final m3eThemeData = buildM3EThemeData(theme);

        expect(
          m3eThemeData.colorScheme.primary,
          equals(theme.colorScheme.primary),
        );
        expect(m3eThemeData.brightness, equals(theme.brightness));
      },
    );

    testWidgets(
      'm3eThemeBridgeBuilder memoizes M3EThemeData when theme does not change',
      (tester) async {
        M3EThemeData? firstM3eTheme;
        M3EThemeData? secondM3eTheme;

        final theme = ThemeData.light();

        await tester.pumpWidget(
          Theme(
            data: theme,
            child: Builder(
              builder: (context) {
                return m3eThemeBridgeBuilder(
                  context,
                  Builder(
                    builder: (ctx) {
                      firstM3eTheme = M3ETheme.of(ctx);
                      return const SizedBox();
                    },
                  ),
                );
              },
            ),
          ),
        );

        expect(firstM3eTheme, isNotNull);

        // Rebuild with identical theme instance
        await tester.pumpWidget(
          Theme(
            data: theme,
            child: Builder(
              builder: (context) {
                return m3eThemeBridgeBuilder(
                  context,
                  Builder(
                    builder: (ctx) {
                      secondM3eTheme = M3ETheme.of(ctx);
                      return const SizedBox();
                    },
                  ),
                );
              },
            ),
          ),
        );

        expect(secondM3eTheme, isNotNull);
        expect(identical(firstM3eTheme, secondM3eTheme), isTrue);
      },
    );

    testWidgets(
      'm3eThemeBridgeBuilder updates M3EThemeData when theme changes',
      (tester) async {
        M3EThemeData? lightM3eTheme;
        M3EThemeData? darkM3eTheme;

        await tester.pumpWidget(
          Theme(
            data: ThemeData.light(),
            child: Builder(
              builder: (context) {
                return m3eThemeBridgeBuilder(
                  context,
                  Builder(
                    builder: (ctx) {
                      lightM3eTheme = M3ETheme.of(ctx);
                      return const SizedBox();
                    },
                  ),
                );
              },
            ),
          ),
        );

        await tester.pumpWidget(
          Theme(
            data: ThemeData.dark(),
            child: Builder(
              builder: (context) {
                return m3eThemeBridgeBuilder(
                  context,
                  Builder(
                    builder: (ctx) {
                      darkM3eTheme = M3ETheme.of(ctx);
                      return const SizedBox();
                    },
                  ),
                );
              },
            ),
          ),
        );

        expect(lightM3eTheme, isNotNull);
        expect(darkM3eTheme, isNotNull);
        expect(identical(lightM3eTheme, darkM3eTheme), isFalse);
        expect(darkM3eTheme!.brightness, equals(Brightness.dark));
      },
    );
  });
}
