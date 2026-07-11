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

  @override
  Widget build(BuildContext context) {
    final info = SettingsTileInfo.of(context);
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(info.isTopTile ? 20 : 3),
            bottom: Radius.circular(info.isBottomTile ? 20 : 3),
          ),
          child: Material(
            color:
                backgroundColor ??
                (theme.brightness == Brightness.light
                    ? theme.colorScheme.surfaceContainerLowest
                    : theme.colorScheme.surfaceContainerHigh),
            child: InkWell(
              onTap: enabled ? () => onTap?.call(context) : null,
              mouseCursor: enabled && onTap != null
                  ? SystemMouseCursors.click
                  : null,
              child: Opacity(
                opacity: enabled ? 1.0 : 0.5,
                child: Padding(padding: padding, child: child),
              ),
            ),
          ),
        ),
        if (info.needDivider) const SizedBox(height: 2),
      ],
    );
  }
}
