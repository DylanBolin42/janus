import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:janus/pages/SettingPage/subSettingPage/planningSetting/cardo_config_dialog.dart';
import 'package:janus/services/cardo/cardo_config.dart';

void main() {
  testWidgets('reload failure stays retryable and uses sandbox file', (
    tester,
  ) async {
    final service = _ReloadService();
    addTearDown(service.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CardoConfigDialog(service: service)),
      ),
    );
    await tester.tap(find.text('重新加载配置'));
    await tester.pump();
    expect(service.paths, [CardoConfigService.configName]);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, '重新加载配置'))
          .onPressed,
      isNull,
    );
    service.pending.completeError(StateError('/private/sensitive/path'));
    await tester.pump();
    expect(find.text('重新加载失败，请重试'), findsOneWidget);
    expect(find.textContaining('/private/sensitive/path'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('重新加载配置'));
    await tester.pump();
    expect(service.paths.length, 2);
    service.pending.complete();
    await tester.pump();
    expect(find.text('重新加载失败，请重试'), findsNothing);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, '重新加载配置'))
          .onPressed,
      isNotNull,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'closing during reload cancels refresh and avoids setState after dispose',
    (tester) async {
      final service = _ReloadService();
      addTearDown(service.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CardoConfigDialog(service: service)),
        ),
      );
      await tester.tap(find.text('重新加载配置'));
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      service.pending.completeError(StateError('failed'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'settings distinguishes rejected candidate from effective configuration',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final service = CardoConfigService();
      addTearDown(service.dispose);
      service.replaceJson('{"thresholds":{"a_min":80}}', source: 'injected');
      service.replaceJson('{"version":99}', source: 'injected');
      if (Platform.environment.containsKey('CARDO_SCREENSHOT')) {
        await tester.runAsync(() async {
          final bytes = await File(
            'assets/fonts/zh_CN/static/NotoSerifSC-Regular.ttf',
          ).readAsBytes();
          final loader = FontLoader('Evidence')
            ..addFont(Future.value(ByteData.sublistView(bytes)));
          await loader.load();
        });
      }
      final boundary = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            fontFamily: Platform.environment.containsKey('CARDO_SCREENSHOT')
                ? 'Evidence'
                : null,
          ),
          home: RepaintBoundary(
            key: boundary,
            child: Scaffold(body: CardoConfigDialog(service: service)),
          ),
        ),
      );
      expect(find.textContaining('生效来源：injected'), findsOneWidget);
      expect(find.textContaining('\nrejected\n'), findsOneWidget);
      expect(find.text('重新加载配置'), findsOneWidget);
      expect(find.textContaining('修订：1'), findsOneWidget);
      // Optional review artifact, outside the source tree.
      if (Platform.environment['CARDO_SCREENSHOT'] case final String output) {
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(output).writeAsBytes(bytes!.buffer.asUint8List());
        });
      }
    },
  );
}

class _ReloadService extends CardoConfigService {
  final paths = <String>[];
  Completer<void> pending = Completer<void>();

  @override
  Future<void> watchFile(
    String path, {
    Duration interval = const Duration(seconds: 2),
  }) {
    paths.add(path);
    pending = Completer<void>();
    return pending.future;
  }
}
