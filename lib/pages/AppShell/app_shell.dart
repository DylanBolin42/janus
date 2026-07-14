import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:janus/router/route_constants.dart';
import 'package:janus/shared/custom_appbar.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final String? routeName = GoRouterState.of(context).name;
    final String title = routeName != null
        ? (RouteDisplayName.names[routeName] ?? routeName)
        : 'Janus';

    return GlassScaffold(
      topEdgeFade: false,
      appBar: CustomAppbar(
        title: title,
        actions: [
          GlassIconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.pushNamed('setting'),
          ),
        ],
      ),
      body: CustomAppbar.wrapBody(context, child),
      bottomBar: GlassTabBar.bottom(
        extraButton: GlassBottomBarExtraButton(
          icon: Icon(Icons.add_rounded),
          onTap: () {}, //TODO: 添加功能
          label: 'Add',
        ),
        selectedIconColor: Theme.of(context).colorScheme.primary,
        selectedLabelColor: Theme.of(context).colorScheme.primary,
        unselectedIconColor: Theme.of(context).colorScheme.onSurfaceVariant,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        tabs: [
          GlassTab(icon: Icon(Icons.inbox_rounded), label: 'Inbox'),
          GlassTab(icon: Icon(Icons.task_rounded), label: 'Tasks'),
          GlassTab(icon: Icon(Icons.lock_clock_rounded), label: 'Focus'),
          GlassTab(icon: Icon(Icons.insights_rounded), label: 'Insights'),
        ],
        selectedIndex: _calculateSelectedIndex(context),
        onTabSelected: (int index) => _onItemTapped(index, context),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(RoutePath.inbox)) return 0;
    if (location.startsWith(RoutePath.task)) return 1;
    if (location.startsWith(RoutePath.focus)) return 2;
    if (location.startsWith(RoutePath.insights)) return 3;
    return 0;
  }

  static void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.goNamed('inbox');
      case 1:
        context.goNamed('task');
      case 2:
        context.goNamed('focus');
      case 3:
        context.goNamed('insights');
    }
  }
}
