// 回归测试：material_3_expressive 1.0.8+ 内部使用 material_ui（Flutter
// Material 的 fork），其 TextField 需要 material_ui 自己的 MaterialLocalizations。
// 若应用未注册 material_ui 的本地化委托，会抛 "No MaterialLocalizations found"
// （见 lib/main.dart 中的修复）。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as mui;

void main() {
  testWidgets('material_ui TextField 缺少本地化委托时抛 No MaterialLocalizations', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: mui.Scaffold(body: mui.TextField())),
    );

    final exception = tester.takeException();
    expect(exception, isNotNull);
    expect(exception.toString(), contains('No MaterialLocalizations found'));
  });

  testWidgets('注册 material_ui 本地化委托后不再崩溃', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        // 与应用入口 lib/main.dart 保持一致
        localizationsDelegates: const [
          mui.GlobalMaterialLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        home: const mui.Scaffold(body: mui.TextField()),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
