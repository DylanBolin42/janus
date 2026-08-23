import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/pages/TaskCreationPage/subPage/classic_page.dart';
import 'package:janus/theme/m3e_bridge.dart';
import 'package:janus/theme/theme.dart';
import 'package:material_ui/material_ui.dart' as mui;

/// 与应用入口 lib/main.dart 保持一致：builder 里注入与全局主题同步的
/// M3ETheme，否则 M3E 组件会回退到 material_ui 的静态 fallback 主题。
Widget createClassicPage({ThemeMode themeMode = ThemeMode.light}) {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      builder: m3eThemeBridgeBuilder,
      // 与应用入口 lib/main.dart 保持一致：material_3_expressive 1.0.8+
      // 内部使用 material_ui（Material fork），需要注册它自己的本地化委托。
      localizationsDelegates: const [
        mui.GlobalMaterialLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      home: const Scaffold(body: ClassicPage()),
    ),
  );
}

void _setLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

/// 打开标签下拉框（等展开动画结束）。
Future<void> _openTagDropdown(WidgetTester tester) async {
  await tester.tap(find.text('请选择标签'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('ClassicPage renders without crashing', (tester) async {
    _setLargeViewport(tester);

    await tester.pumpWidget(createClassicPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
  });

  testWidgets('Opening tag dropdown does not crash', (tester) async {
    _setLargeViewport(tester);

    await tester.pumpWidget(createClassicPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // 打开标签下拉框：searchEnabled: true 会渲染 material_ui 的搜索
    // TextField，若缺少 material_ui.MaterialLocalizations 会抛
    // "No MaterialLocalizations found"。
    await _openTagDropdown(tester);

    expect(tester.takeException(), isNull);
  });

  testWidgets('Tag dropdown follows the global dark theme', (tester) async {
    _setLargeViewport(tester);

    // 回归测试：M3ETheme.of 若回退到 material_ui 的静态 fallback 主题，
    // 下拉面板/字段背景将恒为浅色；注入 m3eThemeBridgeBuilder 后应取到
    // 暗色主题的 surfaceContainerHighest。
    await tester.pumpWidget(createClassicPage(themeMode: ThemeMode.dark));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await _openTagDropdown(tester);
    expect(tester.takeException(), isNull);
    // 面板确实展开了（material_ui 搜索框的放大镜图标）。
    expect(find.byIcon(Icons.search), findsWidgets);

    final darkSurfaceHighest =
        AppTheme.dark.colorScheme.surfaceContainerHighest;
    final fallbackLightHighest =
        ThemeData.fallback().colorScheme.surfaceContainerHighest;
    // 两个色值必须不同，否则断言失去意义。
    expect(darkSurfaceHighest, isNot(fallbackLightHighest));

    // 字段与面板背景来自暗色主题（material_ui 的 Material）。
    final themedPanel = find.byWidgetPredicate(
      (w) => w is mui.Material && w.color == darkSurfaceHighest,
    );
    expect(themedPanel, findsWidgets);

    // 不应残留 fallback 浅色主题的 surfaceContainerHighest。
    final stalePanel = find.byWidgetPredicate(
      (w) => w is mui.Material && w.color == fallbackLightHighest,
    );
    expect(stalePanel, findsNothing);
  });
}
