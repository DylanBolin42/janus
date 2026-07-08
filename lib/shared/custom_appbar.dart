import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:card_settings_ui/card_settings_ui.dart';

/// A gradient AppBar with an absolutely centered title, auto back button,
/// and action slots.
///
/// Renders a [LinearGradient] from [ColorScheme.surface] (opaque at top) to
/// fully transparent at bottom. Implements [PreferredSizeWidget] so it can
/// be passed directly to [GlassScaffold.appBar].
///
/// Since [GlassScaffold] uses [extendBody] by default, the body content
/// extends behind the AppBar and is visible through the transparent bottom
/// portion of the gradient.
///
/// Use [CustomAppbar.wrapBody] to add appropriate top padding to scroll
/// views so their content starts below the opaque portion of the gradient.
///
/// Usage:
/// ```dart
/// GlassScaffold(
///   topEdgeFade: false,
///   appBar: CustomAppbar(
///     title: '设置',
///     showBack: true,
///   ),
///   body: CustomAppbar.wrapBody(
///     context,
///     SettingsList(sections: [...]),
///   ),
/// )
/// ```
class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar({
    required this.title,
    this.showBack = false,
    this.actions,
    super.key,
  });

  /// Title text displayed at the absolute center.
  final String title;

  /// Whether to show a [GlassIconButton] with a back arrow on the left.
  ///
  /// Calls [context.pop()] when tapped.
  final bool showBack;

  /// Optional action widgets on the trailing (right) side.
  final List<Widget>? actions;

  /// The gradient box height in logical pixels (toolbar portion only,
  /// excluding status bar padding).
  static const double height = kToolbarHeight; // 56.0

  /// Top padding: status-bar safe-area + 8px breathing room.
  static double topPad(BuildContext context) =>
      MediaQuery.of(context).padding.top + 8;

  /// The vertical offset from the screen top where body content should begin.
  ///
  /// This accounts for the status bar, breathing room, and the portion of
  /// the gradient bar that is opaque enough to obscure content (~45% from top).
  static double bodyTopOffset(BuildContext context) =>
      topPad(context) + height * 0.45 + 16;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  /// 构建渐变 AppBar。
  ///
  /// 创建一个包含状态栏安全区域的 SizedBox，并在其上应用从 opaque 到 transparent
  /// 的渐变色。渐变采用非线性渐变，使得越靠近底部透明度变化越快，符合 iOS 26 视觉规范。
  /// 内部包含标题、返回按钮和操作项。
  Widget _buildGradientBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pad = topPad(context);

    return SizedBox(
      height: pad + height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cs.surface, // 0.0 -> 不透明
              cs.surface.withValues(alpha: 0.99), // 0.2
              cs.surface.withValues(alpha: 0.94), // 0.4
              cs.surface.withValues(alpha: 0.78), // 0.6
              cs.surface.withValues(alpha: 0.49), // 0.8
              cs.surface.withValues(alpha: 0.0), // 1.0 -> 完全透明
            ],
            stops: const [0.0, 0.2, 0.4, 0.6, 0.9, 1.0],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: pad),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                // ── 返回按钮（左侧） ──────────────────────────────────
                if (showBack)
                  Positioned(
                    left: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GlassIconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ),

                // ── 标题（绝对居中） ────────────────────────────
                Center(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // ── 操作项（右侧） ────────────────────────────────────
                if (actions != null)
                  Positioned(
                    right: 16,
                    top: 0,
                    bottom: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions!,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 为 body 内容添加顶部内边距，使其初始位置处于渐变 AppBar 下方，
  /// 同时滚动时可以延伸到 AppBar 透明区域后方。
  ///
  /// 支持的 body 类型：
  /// - [SettingsList]：增加 contentPadding 的 top 值
  /// - [SingleChildScrollView]：增加 padding 的 top 值
  /// - [CustomScrollView]：在 slivers 前面插入一个占位 Sliver
  /// - [Padding]（包裹上述类型）：递归调整子组件
  /// - 其他类型：包裹一层 [Padding]
  ///
  /// 返回值始终是调整后的 Widget。
  static Widget wrapBody(BuildContext context, Widget body) {
    final topOffset = bodyTopOffset(context);
    final (adjusted, wasAdjusted) = _adjustPadding(context, body, topOffset);

    if (wasAdjusted) return adjusted;

    // 无法识别的组件类型，统一用 Padding 包裹
    return Padding(
      padding: EdgeInsets.only(top: topPad(context) + height),
      child: body,
    );
  }

  /// 递归调整滚动组件的内边距。
  static (Widget, bool) _adjustPadding(
    BuildContext context,
    Widget widget,
    double topOffset,
  ) {
    if (widget is SettingsList) {
      return (
        SettingsList(
          sections: widget.sections,
          shrinkWrap: widget.shrinkWrap,
          maxWidth: widget.maxWidth,
          physics: widget.physics,
          contentPadding:
              (widget.contentPadding ??
                      const EdgeInsets.symmetric(vertical: 20))
                  .add(EdgeInsets.only(top: topOffset)),
        ),
        true,
      );
    }

    if (widget is SingleChildScrollView) {
      return (
        SingleChildScrollView(
          key: widget.key,
          scrollDirection: widget.scrollDirection,
          reverse: widget.reverse,
          padding: (widget.padding ?? EdgeInsets.zero).add(
            EdgeInsets.only(top: topOffset),
          ),
          primary: widget.primary,
          physics: widget.physics,
          controller: widget.controller,
          dragStartBehavior: widget.dragStartBehavior,
          clipBehavior: widget.clipBehavior,
          restorationId: widget.restorationId,
          keyboardDismissBehavior: widget.keyboardDismissBehavior,
          child: widget.child,
        ),
        true,
      );
    }

    if (widget is CustomScrollView) {
      return (
        CustomScrollView(
          key: widget.key,
          scrollDirection: widget.scrollDirection,
          reverse: widget.reverse,
          controller: widget.controller,
          primary: widget.primary,
          physics: widget.physics,
          scrollBehavior: widget.scrollBehavior,
          shrinkWrap: widget.shrinkWrap,
          center: widget.center,
          anchor: widget.anchor,
          scrollCacheExtent: widget.scrollCacheExtent,
          semanticChildCount: widget.semanticChildCount,
          dragStartBehavior: widget.dragStartBehavior,
          keyboardDismissBehavior: widget.keyboardDismissBehavior,
          restorationId: widget.restorationId,
          clipBehavior: widget.clipBehavior,
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: topOffset)),
            ...widget.slivers,
          ],
        ),
        true,
      );
    }

    if (widget is Padding) {
      if (widget.child == null) return (widget, false);
      final (adjustedChild, adjusted) = _adjustPadding(
        context,
        widget.child!,
        topOffset,
      );
      return (Padding(padding: widget.padding, child: adjustedChild), adjusted);
    }

    return (widget, false);
  }

  @override
  Widget build(BuildContext context) {
    return _buildGradientBar(context);
  }
}
