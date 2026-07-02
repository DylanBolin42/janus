import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class Settingpage extends StatefulWidget {
  const Settingpage({super.key});

  @override
  State<Settingpage> createState() => _SettingpageState();
}

class _SettingpageState extends State<Settingpage> {
  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      body: Column(
        children: [
          Text('设置', style: TextTheme().displayLarge),
          GlassCard(
            child: Column(
              children: [
                GlassListTile(
                  title: Text('通用', style: TextTheme().displayLarge),
                  leading: Icon(Icons.settings_rounded),
                  subtitle: Text(
                    '外观、语言及权限设置，定制属于你的Janus！',
                    style: TextTheme().bodySmall,
                  ),
                ),
                GlassListTile(
                  title: Text('通知', style: TextTheme().displayLarge),
                  leading: Icon(Icons.notifications_rounded),
                  subtitle: Text('管理通知行为等', style: TextTheme().bodySmall),
                ),
                GlassListTile(
                  title: Text('专注', style: TextTheme().displayLarge),
                  leading: Icon(Icons.filter_center_focus_rounded),
                  subtitle: Text('专注模式的设置和场景配置等', style: TextTheme().bodySmall),
                ),
                GlassListTile(
                  title: Text('数据', style: TextTheme().displayLarge),
                  leading: Icon(Icons.dataset_rounded),
                  subtitle: Text('数据、日志的记录等', style: TextTheme().bodySmall),
                ),
                GlassListTile(
                  title: Text('同步', style: TextTheme().displayLarge),
                  leading: Icon(Icons.cloud_sync_rounded),
                  subtitle: Text(
                    '云端同步设置，实现跨设备数据流转',
                    style: TextTheme().bodySmall,
                  ),
                ),
                GlassListTile(
                  title: Text('关于', style: TextTheme().displayLarge),
                  leading: Icon(Icons.info_rounded),
                  subtitle: Text(
                    '版本检测、隐私条款、开源许可等',
                    style: TextTheme().bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
