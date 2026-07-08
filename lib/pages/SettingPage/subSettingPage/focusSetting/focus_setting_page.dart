import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:card_settings_ui/list/settings_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/shared/custom_appbar.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';

class FocusSettingPage extends ConsumerStatefulWidget {
  const FocusSettingPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FocusSettingPageState();
}

class _FocusSettingPageState extends ConsumerState<FocusSettingPage> {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GlassScaffold(
      topEdgeFade: false,
      appBar: const CustomAppbar(title: '专注', showBack: true),
      body: CustomAppbar.wrapBody(
        context,
        SettingsList(
          sections: [
            SettingsSection(
              tiles: [
                SettingsTile(
                  title: const Text('默认专注模式'),
                  trailing: GlassSegmentedControl(
                    onSegmentSelected: (_) {},
                    selectedIndex: 0,
                    segments: [
                      GlassSegment(label: '倒计时'),
                      GlassSegment(label: '正计时'),
                      GlassSegment(label: '番茄钟'),
                    ],
                  ), //TODO: 创建切换和存储逻辑
                ),
              ],
            ),
            SettingsSection(
              title: Text('行为', style: tt.titleMedium),
              tiles: [
                SettingsTile(
                  title: Text('自动DND'),
                  trailing: GlassSwitch(value: false, onChanged: (_) {}),
                ), //TODO: 添加逻辑和存储
                SettingsTile(
                  title: Text('通知折叠'),
                  trailing: GlassSwitch(value: false, onChanged: (_) {}),
                ), //TODO: 添加逻辑和存储
                SettingsTile.navigation(
                  title: Text('应用白名单'),
                  description: Text('在专注期间允许访问的程序'),
                ),
              ],
            ),
            SettingsSection(
              title: Text('暂离'),
              tiles: [SettingsTile(title: Text('单次暂离时长'))],
            ),
          ],
        ),
      ),
    );
  }
}
