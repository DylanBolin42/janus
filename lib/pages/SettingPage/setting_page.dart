import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:janus/router/route_constants.dart';
import 'package:janus/theme/theme.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:card_settings_ui/card_settings_ui.dart';

class Settingpage extends StatefulWidget {
  const Settingpage({super.key});

  @override
  State<Settingpage> createState() => _SettingpageState();
}

class _SettingpageState extends State<Settingpage> {
  @override
  Widget build(BuildContext context) {
    final String title = RouteDisplayName.names['setting'] ?? '设置';

    return GlassScaffold(
      appBar: GlassAppBar(
        leading: GlassIconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(RoutePath.inbox),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          children: [
            SizedBox(height: AppSpacing.topSafeArea),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('设置', style: Theme.of(context).textTheme.headlineLarge),
              ],
            ),
            Expanded(
              child: SettingsList(
                sections: [
                  SettingsSection(
                    tiles: [
                      SettingsTile.navigation(
                        title: Text('通用'),
                        leading: Icon(Icons.settings_rounded),
                        description: Text('外观、语言及权限设置，定制属于你的Janus！'),
                        onPressed: (_) {
                          context.goNamed('generalSetting');
                        },
                      ),
                      SettingsTile.navigation(
                        title: Text('通知'),
                        leading: Icon(Icons.notifications_rounded),
                        description: Text('管理通知行为等'),
                        onPressed: (_) {},
                      ),
                      SettingsTile.navigation(
                        title: Text('专注'),
                        leading: Icon(Icons.filter_center_focus_rounded),
                        description: Text('专注模式的设置和场景配置等'),
                        onPressed: (_) {},
                      ),
                      SettingsTile.navigation(
                        title: Text('数据'),
                        leading: Icon(Icons.dataset_rounded),
                        description: Text('数据、日志的记录等'),
                        onPressed: (_) {},
                      ),
                      SettingsTile.navigation(
                        title: Text('同步'),
                        leading: Icon(Icons.cloud_sync_rounded),
                        description: Text('云端同步设置，实现跨设备数据流转'),
                        onPressed: (_) {},
                      ),
                      SettingsTile.navigation(
                        title: Text('关于'),
                        leading: Icon(Icons.info_rounded),
                        description: Text('版本检测、隐私条款、开源许可等'),
                        onPressed: (_) {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
