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
  testWidgets(
    'settings distinguishes rejected candidate from effective configuration',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final service = CardoConfigService();
      addTearDown(service.dispose);
      service.replaceJson(
        '{"thresholds":{"a_min":80}}',
        source: '/config/cardo.json',
      );
      service.replaceJson('{"version":99}', source: '/config/rejected.json');
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
      expect(find.textContaining('生效来源：/config/cardo.json'), findsOneWidget);
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
