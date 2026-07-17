import 'package:flutter/material.dart';
import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:card_settings_ui/tile/settings_tile_info.dart';
import 'package:janus/shared/custom_app_settings_tile.dart';

/// 一个灵活的设置项 tile 组件，是 [CustomAppSettingsTile] 的简写别名。
///
/// 与 [CustomAppSettingsTile] 完全一致，只是名称更短，便于在灵活布局中使用。
/// 它可以放在 [FlexRow]、[Row]、[Column]、[Wrap] 等任意容器中自由布局。
///
/// [isLeftEdge] 和 [isRightEdge] 用于控制圆角行为——当 tile 位于 [FlexRow]
/// 的最左侧或最右侧时，对应角会使用大圆角（20px），否则使用小圆角（3px）。
/// 独立使用（不在 [FlexRow] 中）时默认为 `true`。
///
/// 用法：
/// ```dart
/// FlexRow(
///   children: [
///     FlexTile(
///       onTap: (ctx) => doSomething(),
///       child: Column(
///         children: [
///           Icon(Icons.add),
///           SizedBox(height: 8),
///           Text('新建'),
///         ],
///       ),
///     ),
///     FlexTile(
///       child: Column(
///         children: [
///           Icon(Icons.delete),
///           SizedBox(height: 8),
///           Text('删除'),
///         ],
///       ),
///     ),
///   ],
/// )
/// ```
class FlexTile extends StatelessWidget {
  const FlexTile({
    required this.child,
    this.onTap,
    this.enabled = true,
    this.backgroundColor,
    this.padding,
    this.isLeftEdge = true,
    this.isRightEdge = true,
    super.key,
  });

  /// Tile 内部的自定义内容树。
  final Widget child;

  /// 点击回调。为 `null` 时 tile 仍有点击水波纹反馈，但不执行任何操作。
  final Function(BuildContext)? onTap;

  /// 是否启用。为 `false` 时不可点击且内容半透明。
  final bool enabled;

  /// 背景色。为 `null` 时根据主题自动选择。
  final Color? backgroundColor;

  /// Tile 内部的内边距，为 `null` 时使用 [CustomAppSettingsTile] 的默认值。
  final EdgeInsetsGeometry? padding;

  /// 是否为行的左边缘 tile。
  ///
  /// 由 [FlexRow] 自动设置，独立使用时默认为 `true`。
  final bool isLeftEdge;

  /// 是否为行的右边缘 tile。
  ///
  /// 由 [FlexRow] 自动设置，独立使用时默认为 `true`。
  final bool isRightEdge;

  @override
  Widget build(BuildContext context) {
    return CustomAppSettingsTile(
      onTap: onTap ?? (_) {},
      enabled: enabled,
      backgroundColor: backgroundColor,
      padding:
          padding ??
          const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 24),
      isLeftEdge: isLeftEdge,
      isRightEdge: isRightEdge,
      child: child,
    );
  }
}

/// 一组横向排列的 [FlexTile]，自动添加 tile 之间的间距，并自动判断
/// 每个 tile 是否位于行的左右边缘，以决定是否使用大圆角。
///
/// 位于行最左侧的 tile 的左上/左下角会使用大圆角，位于最右侧的 tile 的
/// 右上/右下角会使用大圆角，中间的 tile 则使用默认小圆角。
/// 同时会结合 [FlexSettingSection] 的 `SettingsTileInfo` 上下文来判断
/// 分组顶部/底部的圆角。
///
/// 类似于 [SettingsSection] 在垂直方向上的 tile 之间自动添加
/// [SizedBox(height: 2)] 作为分隔，[FlexRow] 在水平方向上的
/// [FlexTile] 之间自动添加 [SizedBox(width: 2)]。
///
/// 用法：
/// ```dart
/// FlexRow(
///   children: [
///     FlexTile(child: Text('左侧')),
///     FlexTile(child: Text('右侧')),
///   ],
/// )
/// ```
class FlexRow extends StatelessWidget {
  const FlexRow({required this.children, this.spacing = 2, super.key});

  /// 横向排列的 tile 列表。
  final List<FlexTile> children;

  /// tile 之间的间距，默认 2（与 [SettingsSection] 的纵向分隔高度一致）。
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          Expanded(child: _wrapWithEdgeInfo(children[i], i, children.length)),
        ],
      ],
    );
  }

  /// 根据 tile 在行中的位置自动设置 [isLeftEdge]/[isRightEdge]。
  static FlexTile _wrapWithEdgeInfo(FlexTile tile, int index, int total) {
    return FlexTile(
      key: tile.key,
      onTap: tile.onTap,
      enabled: tile.enabled,
      backgroundColor: tile.backgroundColor,
      padding: tile.padding,
      isLeftEdge: index == 0,
      isRightEdge: index == total - 1,
      child: tile.child,
    );
  }
}

/// 一个自定义灵活布局的设置项分组（section），兼容 [card_settings_ui] 的布局风格。
///
/// 与 [SettingsSection] 的不同之处在于：
/// - [tiles] 接收 [List<Widget>]，每个元素**可以是任意 Widget**，包括：
///   - [FlexTile] 或 [CustomAppSettingsTile]
///   - [Row] 包裹的多个 [FlexTile]（横向排列）
///   - [Column]、[Wrap]、[SizedBox] 等任意布局组件
/// - 不会自动包裹 [SettingsTileInfo]，因此 tile 的圆角/分隔线由每个 tile
///   自身决定（[FlexTile]/[CustomAppSettingsTile] 内部有默认行为）。
///
/// 用法：
/// ```dart
/// SettingsList(
///   sections: [
///     // 横向并排两个 tile，间距自动处理
///     FlexSettingSection(
///       title: Text('操作'),
///       tiles: [
///         FlexRow(
///           children: [
///             FlexTile(
///               onTap: (ctx) => create(),
///               child: Column(children: [
///                 Icon(Icons.add),
///                 Text('新建'),
///               ]),
///             ),
///             FlexTile(
///               onTap: (ctx) => delete(),
///               child: Column(children: [
///                 Icon(Icons.delete),
///                 Text('删除'),
///               ]),
///             ),
///           ],
///         ),
///         // 通栏 tile
///         FlexTile(
///           child: Row(children: [
///             Icon(Icons.info),
///             SizedBox(width: 12),
///             Text('状态：正常'),
///           ]),
///         ),
///       ],
///     ),
///   ],
/// )
/// ```
class FlexSettingSection extends AbstractSettingsSection {
  const FlexSettingSection({
    required this.tiles,
    this.margin,
    this.title,
    this.bottomInfo,
    super.key,
  });

  /// 该分组中的 tile 组件列表。
  ///
  /// 每个元素可以是任意 Widget，包括 [FlexTile]、[CustomAppSettingsTile]，
  /// 或者用 [Row] 包裹的多个 tile 等。
  final List<Widget> tiles;

  /// 分组的外边距。为 `null` 时使用与 [SettingsSection] 相同的默认值。
  final EdgeInsetsDirectional? margin;

  /// 分组标题（显示在 tiles 上方）。
  final Widget? title;

  /// 分组底部信息（显示在 tiles 下方）。
  final Widget? bottomInfo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          margin ??
          const EdgeInsetsDirectional.only(start: 16, end: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(10),
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
                child: title!,
              ),
            ),
          // 用 SettingsTileInfo 包裹每个 tile，让内部的 CustomAppSettingsTile
          // 能正确判断分组顶部/底部边缘，从而应用正确的圆角。
          for (int i = 0; i < tiles.length; i++)
            SettingsTileInfo(
              isTopTile: i == 0,
              isBottomTile: i == tiles.length - 1,
              needDivider: i != tiles.length - 1,
              child: tiles[i],
            ),
          if (bottomInfo != null)
            Padding(
              padding: const EdgeInsets.all(10),
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).hintColor,
                  fontWeight: FontWeight.w600,
                ),
                child: bottomInfo!,
              ),
            ),
        ],
      ),
    );
  }
}

/// 与 [SettingsTile] 布局相同的设置项 tile，但不会在无 `onPressed` 回调时
/// 阻塞子组件交互。
///
/// [SettingsTile]（来自 `card_settings_ui`）内部始终为 [InkWell] 设置非 null
/// 的 `onTap`，导致其中的 [GlassTextField]、[GlassPullDownButton] 等交互组件
/// 无法正常接收触摸事件。
///
/// [InteractiveTile] 使用 [CustomAppSettingsTile] 替代，仅在 `onPressed` 非
/// null 时才创建 [InkWell]，从而让子组件可以正常响应交互。
///
/// 用法：
/// ```dart
/// InteractiveTile(
///   leading: Icon(Icons.web),
///   title: Text('WEBDAV地址'),
///   trailing: SizedBox(width: 200, child: GlassTextField()),
/// )
/// ```
class InteractiveTile extends AbstractSettingsTile {
  const InteractiveTile({
    required this.title,
    this.leading,
    this.trailing,
    this.description,
    this.enabled = true,
    this.onPressed,
    super.key,
  });

  /// Tile 左侧的图标/组件。
  final Widget? leading;

  /// Tile 右侧的交互组件（如 [GlassTextField]、[GlassPullDownButton]）。
  final Widget? trailing;

  /// Tile 的主标题。
  final Widget title;

  /// Tile 标题下方的描述文本。
  final Widget? description;

  /// 是否启用。
  final bool enabled;

  /// 点击回调。为 `null` 时 tile 不可点击（不会创建 [InkWell]）。
  final Function(BuildContext)? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveOnPressed = enabled ? onPressed : null;

    return CustomAppSettingsTile(
      onTap: effectiveOnPressed,
      enabled: enabled,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 16,
        vertical: 24,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            IconTheme(
              data: IconThemeData(
                color: enabled
                    ? theme.colorScheme.onSurface
                    : theme.disabledColor,
              ),
              child: leading!,
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          end: trailing != null ? 16 : 0,
                        ),
                        child: DefaultTextStyle(
                          style: TextStyle(
                            color: enabled
                                ? theme.colorScheme.onSurface
                                : theme.disabledColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          child: title,
                        ),
                      ),
                    ),
                    ?trailing,
                  ],
                ),
                if (description != null) ...[
                  const SizedBox(height: 12),
                  DefaultTextStyle(
                    style: TextStyle(
                      color: enabled ? theme.hintColor : theme.disabledColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    child: description!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
