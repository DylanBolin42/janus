import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/providers/settings_provider.dart';
import 'package:janus/router/app_router.dart';
import 'package:janus/theme/m3e_bridge.dart';
import 'package:janus/theme/theme.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart' show GlobalMaterialLocalizations;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the persisted theme mode — changes take effect immediately
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Janus',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: appRouter,
      // material_3_expressive 1.0.8+ 基于 material_ui（Material fork），其组件
      // 通过 M3ETheme.of 取色；若不注入 M3ETheme，会回退到 material_ui 的静态
      // fallback 主题而不随全局主题变化。builder 位于 Navigator/Overlay 之上，
      // 在此注入与全局主题同步的 M3ETheme（见 lib/theme/m3e_bridge.dart）。
      builder: m3eThemeBridgeBuilder,
      // material_3_expressive 1.0.8+ 内部改用 material_ui（Flutter Material 的
      // fork），其 TextField 等组件需要 material_ui 自己的 MaterialLocalizations。
      // 与 Flutter 默认的两个委托同时注册，避免 "No MaterialLocalizations found"。
      localizationsDelegates: const [
        GlobalMaterialLocalizations
            .delegate, // material_ui 的 MaterialLocalizations
        DefaultMaterialLocalizations
            .delegate, // Flutter 的 MaterialLocalizations
        DefaultWidgetsLocalizations.delegate, // Flutter 的 WidgetsLocalizations
      ],
    );
  }
}
