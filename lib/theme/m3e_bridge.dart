import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart' as mui;

/// 把 Flutter 的 [ThemeData] 镜像成等价的 [M3EThemeData]。
///
/// ## 背景
///
/// material_3_expressive 1.0.8+ 内部改用 material_ui（Flutter Material 的
/// fork）实现组件，组件通过 `M3ETheme.of(context)` 取色。`M3ETheme.of` 在
/// 找不到 `M3ETheme` 祖先时，会回退到 material_ui 的 `Theme.of(context)`；
/// 但本应用使用的是 Flutter 的 `MaterialApp`，树中只有 Flutter 的 `Theme`，
/// material_ui 的继承查找必然落空，最终返回硬编码的 `ThemeData.fallback()`
/// （静态浅色主题）。这导致所有未包在 `M3ETheme` 里的 M3E 组件（如下拉菜单的
/// 面板、搜索框、选项底色等）不随全局主题变化。
///
/// 本函数用 Flutter 主题的色板/字型直接构造等价的 M3E 主题，作为
/// [m3eThemeBridgeBuilder] 的数据源。
M3EThemeData buildM3EThemeData(ThemeData theme) {
  return M3EThemeData(
    colorScheme: _toM3eColorScheme(theme.colorScheme),
    typeScale: M3ETypeScale.fromTextTheme(_toMuiTextTheme(theme.textTheme)),
    iconTheme: theme.iconTheme,
    visualDensity: theme.visualDensity.vertical,
    platform: theme.platform,
    useMaterial3: theme.useMaterial3,
    splashColor: theme.splashColor,
    highlightColor: theme.highlightColor,
  );
}

/// 与 `MaterialApp.builder` 配套的桥接 builder。
///
/// 在 Navigator/Overlay 之上注入与全局主题同步的 [M3ETheme]，使 M3E 组件
/// （包括通过 OverlayPortal 渲染、挂在根 Overlay 上的下拉面板）都能取到
/// 真实的主题色。挂在 builder 里是必须的：只有位于 Overlay 之上的祖先，
/// 面板（overlay child）才能通过继承查找到。
Widget m3eThemeBridgeBuilder(BuildContext context, Widget? child) {
  return _M3EThemeBridgeWidget(child: child);
}

/// 内部 Widget，通过缓存 [M3EThemeData] 避免每次父级重建时重复构造等价主题。
class _M3EThemeBridgeWidget extends StatefulWidget {
  const _M3EThemeBridgeWidget({this.child});

  final Widget? child;

  @override
  State<_M3EThemeBridgeWidget> createState() => _M3EThemeBridgeWidgetState();
}

class _M3EThemeBridgeWidgetState extends State<_M3EThemeBridgeWidget> {
  ThemeData? _cachedTheme;
  M3EThemeData? _cachedM3eTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ⚡ Bolt Optimization: Memoize M3EThemeData construction.
    // Rebuilding buildM3EThemeData on every widget build allocates new
    // M3EColorScheme and M3ETypeScale objects. Caching avoids unnecessary
    // allocations when theme properties haven't changed.
    if (_cachedTheme != theme || _cachedM3eTheme == null) {
      _cachedTheme = theme;
      _cachedM3eTheme = buildM3EThemeData(theme);
    }

    return M3ETheme(
      data: _cachedM3eTheme!,
      child: widget.child ?? const SizedBox.shrink(),
    );
  }
}

M3EColorScheme _toM3eColorScheme(ColorScheme cs) {
  final isDark = cs.brightness == Brightness.dark;
  return M3EColorScheme(
    brightness: cs.brightness,
    // ── Material 3 标准色位 ────────────────────────────────────────────
    primary: cs.primary,
    onPrimary: cs.onPrimary,
    primaryContainer: cs.primaryContainer,
    onPrimaryContainer: cs.onPrimaryContainer,
    secondary: cs.secondary,
    onSecondary: cs.onSecondary,
    secondaryContainer: cs.secondaryContainer,
    onSecondaryContainer: cs.onSecondaryContainer,
    tertiary: cs.tertiary,
    onTertiary: cs.onTertiary,
    tertiaryContainer: cs.tertiaryContainer,
    onTertiaryContainer: cs.onTertiaryContainer,
    error: cs.error,
    onError: cs.onError,
    errorContainer: cs.errorContainer,
    onErrorContainer: cs.onErrorContainer,
    surface: cs.surface,
    onSurface: cs.onSurface,
    onSurfaceVariant: cs.onSurfaceVariant,
    surfaceContainerLowest: cs.surfaceContainerLowest,
    surfaceContainerLow: cs.surfaceContainerLow,
    surfaceContainer: cs.surfaceContainer,
    surfaceContainerHigh: cs.surfaceContainerHigh,
    surfaceContainerHighest: cs.surfaceContainerHighest,
    surfaceDim: cs.surfaceDim,
    surfaceBright: cs.surfaceBright,
    inverseSurface: cs.inverseSurface,
    onInverseSurface: cs.onInverseSurface,
    inversePrimary: cs.inversePrimary,
    outline: cs.outline,
    outlineVariant: cs.outlineVariant,
    shadow: cs.shadow,
    scrim: cs.scrim,
    surfaceTint: cs.surfaceTint,
    // ── M3E 扩展语义色位（与 M3EColorScheme.fromColorScheme 同源逻辑） ──
    emphasis: cs.primary,
    onEmphasis: cs.onPrimary,
    info: cs.tertiary,
    success: isDark
        ? const Color(0xFF81C784)
        : const Color(0xFF2E7D32), //TODO: 需要被抽象进theme.dart
    warning: isDark ? const Color(0xFFFFB74D) : const Color(0xFFEF6C00),
    danger: cs.error,
    surfaceStrong: Color.alphaBlend(
      cs.primary.withValues(alpha: 0.06),
      cs.surface,
    ),
    onSurfaceStrong: cs.onSurface,
    outlineStrong: cs.outline,
  );
}

/// M3E 的类型刻度基于 material_ui 的 [mui.TextTheme]，这里把 Flutter 的
/// [TextTheme] 逐角色平移过去（TextStyle 本身是共享类型，直接复用）。
mui.TextTheme _toMuiTextTheme(TextTheme tt) {
  return mui.TextTheme(
    displayLarge: tt.displayLarge,
    displayMedium: tt.displayMedium,
    displaySmall: tt.displaySmall,
    headlineLarge: tt.headlineLarge,
    headlineMedium: tt.headlineMedium,
    headlineSmall: tt.headlineSmall,
    titleLarge: tt.titleLarge,
    titleMedium: tt.titleMedium,
    titleSmall: tt.titleSmall,
    bodyLarge: tt.bodyLarge,
    bodyMedium: tt.bodyMedium,
    bodySmall: tt.bodySmall,
    labelLarge: tt.labelLarge,
    labelMedium: tt.labelMedium,
    labelSmall: tt.labelSmall,
  );
}
