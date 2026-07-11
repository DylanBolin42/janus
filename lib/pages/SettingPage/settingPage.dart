import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:janus/shared/custom_appbar.dart';
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
    final tt = Theme.of(context).textTheme;

    return GlassScaffold(
      topEdgeFade: false,
      appBar: const CustomAppbar(title: '设置', showBack: true),
      body: CustomAppbar.wrapBody(
        context,
        Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: SettingsList(
            sections: [
              SettingsSection(
                title: Text('通用', style: tt.titleMedium),
                tiles: [
                  SettingsTile.navigation(
                    title: const Text('通用'),
                    leading: const Icon(Icons.settings_rounded),
                    description: const Text('外观、语言及权限设置，定制属于你的Janus！'),
                    onPressed: (_) {
                      context.pushNamed('generalSetting');
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: Text('功能', style: tt.titleMedium),
                tiles: [
                  SettingsTile.navigation(
                    title: const Text('规划'),
                    leading: const Icon(Icons.calendar_today_rounded),
                    description: const Text('管理日程的规划逻辑等'),
                    onPressed: (_) {},
                  ),
                  SettingsTile.navigation(
                    title: const Text('通知'),
                    leading: const Icon(Icons.notifications_rounded),
                    description: const Text('管理通知行为等'),
                    onPressed: (_) {
                      context.pushNamed('notificationSetting');
                    },
                  ),
                  SettingsTile.navigation(
                    title: const Text('专注'),
                    leading: const Icon(Icons.filter_center_focus_rounded),
                    description: const Text('专注模式的设置和场景配置等'),
                    onPressed: (_) {
                      context.pushNamed('focusSetting');
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: Text('存储', style: tt.titleMedium),
                tiles: [
                  SettingsTile.navigation(
                    title: const Text('数据'),
                    leading: const Icon(Icons.dataset_rounded),
                    description: const Text('数据、日志的记录等'),
                    onPressed: (_) {
                      context.pushNamed('storageSetting');
                    },
                  ),
                  SettingsTile.navigation(
                    title: const Text('同步'),
                    leading: const Icon(Icons.cloud_sync_rounded),
                    description: const Text('云端同步设置，实现跨设备数据流转'),
                    onPressed: (_) {},
                  ),
                ],
              ),
              SettingsSection(
                title: Text('非必需功能', style: tt.titleMedium),
                tiles: [
                  SettingsTile.navigation(
                    title: const Text('AI'),
                    leading: const Icon(Icons.bubble_chart_rounded),
                    description: const Text('AI相关设置，使用BYOK策略'),
                    onPressed: (_) {},
                  ),
                ],
              ),
              SettingsSection(
                title: Text('应用信息', style: tt.titleMedium),
                tiles: [
                  SettingsTile.navigation(
                    title: const Text('关于'),
                    leading: const Icon(Icons.info_rounded),
                    description: const Text('版本检测、隐私条款、开源许可等'),
                    onPressed: (_) {},
                  ),
                  SettingsTile.navigation(
                    title: const Text('功能说明'),
                    leading: const Icon(Icons.lightbulb_rounded),
                    description: const Text('针对一些复杂功能的辅助性说明'),
                    onPressed: (_) {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
