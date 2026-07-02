import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:janus/router/app_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar(title: Text('Janus')), //TODO: 使用分页面名称
      body: child,
      bottomBar: GlassTabBar.bottom(
        extraButton: GlassBottomBarExtraButton(
          icon: Icon(Icons.add_rounded),
          onTap: () {},
          label: 'Add',
        ),
        tabs: [
          GlassTab(icon: Icon(Icons.home_outlined), label: 'Inbox'),
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
