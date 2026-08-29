import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:janus/pages/TaskCreationPage/task_creation_page.dart';
import 'package:janus/router/route_constants.dart';
import 'package:janus/shared/custom_appbar.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final String? routeName = GoRouterState.of(context).name;
    final String title = routeName != null
        ? (RouteDisplayName.names[routeName] ?? routeName)
        : 'Janus';

    return Material(
      child: GlassScaffold(
        topEdgeFade: true,
        appBar: CustomAppbar(
          title: title,
          actions: [
            GlassButtonGroup.icons(
              borderRadius: 64,
              items: [
                if (_calculateSelectedIndex(context) == 0)
                  GlassButtonGroupItem(
                    icon: const Icon(Icons.filter_list_rounded),
                    onTap: () {},
                  ),
                GlassButtonGroupItem(
                  icon: const Icon(Icons.settings_rounded),
                  onTap: () => context.pushNamed('setting'),
                ),
              ],
            ),
          ],
        ),
        body: child,
        bottomBar: GlassTabBar.bottom(
          extraButton: GlassTabBarExtraButton(
            icon: Icon(Icons.add_rounded),
            //TODO: 修改为WoltModalSheet以增强可读性
            //onTap: () => GlassModalSheet.show(
            //  settings: LiquidGlassSettings(blur: 500, thickness: 0),
            //  halfSize: 0.65,
            //
            //  initialState: GlassSheetState.half,
            //  context: context,
            //  builder: (_) => const TaskCreationPage(),
            //),
            onTap: () => WoltModalSheet.show(
              //TODO: 顶部Row取消中心切换，将按钮组写入ModalSheet的action区域
              context: context,
              pageListBuilder: (modalSheetContext) {
                return TaskCreationPage.createTaskPage(modalSheetContext);
              },
              modalTypeBuilder: (BuildContext context) {
                final width = MediaQuery.sizeOf(context).width;
                if (width < 523) {
                  return const WoltBottomSheetType(
                    shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                  );
                } else {
                  return const WoltSideSheetType(
                    shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.only(
                        topStart: Radius.circular(32),
                        bottomStart: Radius.circular(32),
                      ),
                    ),
                  );
                }
              },
            ),
            label: 'Add',
          ),
          selectedIconColor: Theme.of(context).colorScheme.primary,
          selectedLabelColor: Theme.of(context).colorScheme.primary,
          unselectedIconColor: Theme.of(context).colorScheme.onSurfaceVariant,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          tabs: [
            GlassTab(icon: Icon(Icons.inbox_rounded), label: 'Inbox'),
            GlassTab(icon: Icon(Icons.timeline_rounded), label: 'Timeline'),
            GlassTab(icon: Icon(Icons.lock_clock_rounded), label: 'Focus'),
            GlassTab(icon: Icon(Icons.insights_rounded), label: 'Insights'),
          ],
          selectedIndex: _calculateSelectedIndex(context),
          onTabSelected: (int index) => _onItemTapped(index, context),
        ),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(RoutePath.inbox)) return 0;
    if (location.startsWith(RoutePath.timeline)) return 1;
    if (location.startsWith(RoutePath.focus)) return 2;
    if (location.startsWith(RoutePath.insights)) return 3;
    return 0;
  }

  static void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.goNamed('inbox');
      case 1:
        context.goNamed('timeline');
      case 2:
        context.goNamed('focus');
      case 3:
        context.goNamed('insights');
    }
  }
}
