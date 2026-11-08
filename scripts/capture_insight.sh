#!/usr/bin/env bash
# Headless Insight reference images, using two fixture tasks (not user data).
# Usage from the repo: bash scripts/capture_insight.sh [/absolute/output/directory]
# Requires the existing FVM SDK and resolved project dependencies; no pub changes.
# This helper stays out of normal analyze/build/test discovery. The temporary
# Dart harness lives in ignored .dart_tool and is removed even on failure.
set -euo pipefail
cd "$(dirname "$0")/.."
capture_output="${1:-/tmp}"
mkdir -p "$capture_output" .dart_tool
capture_output="$(cd "$capture_output" && pwd)"
capture_scratch="$(mktemp -d .dart_tool/insight_capture.XXXXXX)"
trap 'rm -rf -- "$capture_scratch"' EXIT
cat > "$capture_scratch/capture_test.dart" <<'DART'
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/database/app_database.dart';
import 'package:janus/pages/InsightPage/insight_page.dart';
import 'package:janus/providers/database_provider.dart';
import 'package:janus/theme/theme.dart';

// This uses two fixture tasks and a headless CJK fallback for reference images.
// It does not capture production user data or verify device font rendering.
void main() {
  testWidgets('theme evidence', (tester) async {
    for (final entry in {
      'GoogleSans': 'assets/fonts/en/GoogleSans/GoogleSansFlex-VariableFont_GRAD,ROND,opsz,slnt,wdth,wght.ttf',
      'EnglishLiterature':
          'assets/fonts/en/Literata/Literata-VariableFont_opsz,wght.ttf',
      'ChineseLiterature':
          'assets/fonts/zh_CN/NotoSerifSC-VariableFont_wght.ttf',
    }.entries) {
      await (FontLoader(
        entry.key,
      )..addFont(rootBundle.load(entry.value))).load();
    }
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final output = Directory(
      const String.fromEnvironment('INSIGHT_CAPTURE_DIR', defaultValue: '/tmp'),
    );
    await tester.runAsync(() => output.create(recursive: true));
    final day = DateTime.now();
    for (final dark in [false, true]) {
      final key = GlobalKey();
      final base = dark ? AppTheme.dark : AppTheme.light;
      final evidenceTheme = base.copyWith(
        textTheme: base.textTheme.apply(
          fontFamilyFallback: ['ChineseLiterature'],
        ),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            insightTasksProvider.overrideWith(
              (ref) => Stream.value([
                Task(
                  id: 1,
                  title: '整理项目资料',
                  status: 1,
                  ddl: day,
                  priority: 1,
                  estHour: 1,
                  estMinute: 30,
                ),
                Task(
                  id: 2,
                  title: '阅读与学习',
                  status: 2,
                  ddl: day,
                  priority: 0,
                  estMinute: 30,
                ),
              ]),
            ),
          ],
          child: MaterialApp(
            theme: evidenceTheme,
            home: RepaintBoundary(
              key: key,
              child: const Scaffold(body: InsightPage()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final shot =
            await (key.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage();
        final bytes = await shot.toByteData(format: ui.ImageByteFormat.png);
        await File('${output.path}/insight-${dark ? 'dark' : 'light'}.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        shot.dispose();
      });
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
  });
}
DART
fvm flutter test --no-pub --dart-define="INSIGHT_CAPTURE_DIR=$capture_output" "$capture_scratch/capture_test.dart"
printf 'Reference images: %s/insight-light.png and %s/insight-dark.png
' "$capture_output" "$capture_output"
