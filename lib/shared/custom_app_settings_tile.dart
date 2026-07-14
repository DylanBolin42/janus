import 'package:flutter/material.dart';
import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:card_settings_ui/tile/settings_tile_info.dart';

/// 一个可自定义内部内容的设置项 tile，保留 [SettingsTile] 的外框、
/// 圆角、背景色和分隔线，但内部布局完全由 [child] 控制。
///
/// 用法：
/// ```dart
/// CustomSettingsSection(
///   tiles: [
///     AppSettingsTile(
///       onTap: (context) => doSomething(),
///       child: Row(
///         children: [
///           FaIcon(FontAwesomeIcons.database),
///           SizedBox(width: 12),
///           Text('自定义内容'),
///           Spacer(),
///           Text('→'),
///         ],
///       ),
///     ),
///   ],
/// )
/// ```
class CustomAppSettingsTile extends AbstractSettingsTile {
  const CustomAppSettingsTile({
    required this.child,
    this.onTap,
    this.enabled = true,
    this.backgroundColor,
    this.padding = const EdgeInsetsDirectional.symmetric(
      horizontal: 16,
      vertical: 24,
    ),
    this.isLeftEdge = true,
    this.isRightEdge = true,
    super.key,
  });

  /// Tile 内部的自定义内容树。
  final Widget child;

  /// 点击回调。为 `null` 时不可点击（没有水波纹）。
  final Function(BuildContext)? onTap;

  /// 是否启用。为 `false` 时不可点击且内容半透明。
  final bool enabled;

  /// 背景色。为 `null` 时根据主题自动选择，与 [SettingsTile] 保持一致。
  final Color? backgroundColor;

  /// Tile 内部的内边距，默认与 [SettingsTile] 的 title 区域一致。
  final EdgeInsetsGeometry padding;

  /// 是否为行的左边缘 tile（水平排列时左上/左下角使用大圆角）。
  ///
  /// 仅在 [FlexRow] 中使用时有意义，独立 tile 默认为 `true`。
  final bool isLeftEdge;

  /// 是否为行的右边缘 tile（水平排列时右上/右下角使用大圆角）。
  ///
  /// 仅在 [FlexRow] 中使用时有意义，独立 tile 默认为 `true`。
  final bool isRightEdge;

  @override
  Widget build(BuildContext context) {
    final info = SettingsTileInfo.of(context);
    final theme = Theme.of(context);

    // ── 四角圆角逻辑 ──────────────────────────────────────────────────────
    // top-left     = 分组顶部 && 行左边缘  → 大圆角
    // top-right    = 分组顶部 && 行右边缘  → 大圆角
    // bottom-left  = 分组底部 && 行左边缘  → 大圆角
    // bottom-right = 分组底部 && 行右边缘  → 大圆角
    // 其他情况一律使用默认小圆角（3px）
    const double largeRadius = 20;
    const double smallRadius = 3;

    final double topLeft = (info.isTopTile && isLeftEdge)
        ? largeRadius
        : smallRadius;
    final double topRight = (info.isTopTile && isRightEdge)
        ? largeRadius
        : smallRadius;
    final double bottomLeft = (info.isBottomTile && isLeftEdge)
        ? largeRadius
        : smallRadius;
    final double bottomRight = (info.isBottomTile && isRightEdge)
        ? largeRadius
        : smallRadius;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topLeft),
            topRight: Radius.circular(topRight),
            bottomLeft: Radius.circular(bottomLeft),
            bottomRight: Radius.circular(bottomRight),
          ),
          child: Material(
            color:
                backgroundColor ??
                (theme.brightness == Brightness.light
                    ? theme.colorScheme.surfaceContainerLowest
                    : theme.colorScheme.surfaceContainerHigh),
            child: enabled && onTap != null
                ? InkWell(
                    onTap: () => onTap!.call(context),
                    mouseCursor: SystemMouseCursors.click,
                    child: Opacity(
                      opacity: enabled ? 1.0 : 0.5,
                      child: Padding(padding: padding, child: child),
                    ),
                  )
                : Opacity(
                    opacity: enabled ? 1.0 : 0.5,
                    child: Padding(padding: padding, child: child),
                  ),
          ),
        ),
        if (info.needDivider) const SizedBox(height: 2),
      ],
    );
  }
}
