import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:card_settings_ui/list/settings_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/models/app_settings.dart';
import 'package:janus/providers/settings_provider.dart';
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
  late final settings =
      ref.watch(appSettingsNotifierProvider).valueOrNull ?? const AppSettings();

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
              tiles: [
                SettingsTile(
                  title: Text('单次暂离时长'),
                  trailing: GlassPullDownButton(
                    label: settings.tempLeaveDuration.label,
                    buttonWidth: 120,
                    buttonShape: const LiquidRoundedRectangle(borderRadius: 64),
                    items: TempLeaveDuration.values.map((duration) {
                      final isSelected = settings.tempLeaveDuration == duration;
                      return GlassMenuItem(
                        title: duration.label,
                        icon: Icon(
                          isSelected ? Icons.check_rounded : null,
                          size: 20,
                        ),
                        isSelected: isSelected,
                        onTap: () {
                          ref
                              .read(appSettingsNotifierProvider.notifier)
                              .setTempLeaveDuration(duration);
                        },
                      );
                    }).toList(),
                  ),
                ),
                SettingsTile(
                  title: Text('单次专注最大暂离次数'),
                  trailing: GlassPullDownButton(
                    label: settings.tempLeaveTimes.label,
                    buttonWidth: 120,
                    buttonShape: const LiquidRoundedRectangle(borderRadius: 64),
                    items: TempLeaveTimes.values.map((times) {
                      final isSelected = settings.tempLeaveTimes == times;
                      return GlassMenuItem(
                        title: times.label,
                        icon: Icon(
                          isSelected ? Icons.check_rounded : null,
                          size: 20,
                        ),
                        isSelected: isSelected,
                        onTap: () {
                          ref
                              .read(appSettingsNotifierProvider.notifier)
                              .setTempLeaveTimes(times);
                        },
                      );
                    }).toList(),
                  ),
                ),
                SettingsTile.navigation(
                  title: Text('应用白名单'),
                  description: Text('可以在专注过程中正常访问，推荐不要把流媒体平台、游戏等易打断专注的软件加入白名单'),
                ), //TODO: 创建白名单页面
              ],
            ),
            SettingsSection(
              title: Text('场景'),
              tiles: [
                SettingsTile(
                  title: Text('场景渲染引擎'),
                  trailing: GlassPullDownButton(
                    //TODO: 添加渲染引擎描述和建议
                    // TODO: 可以适当添加商标icon
                    label: settings.focusSceneRenderMode.label,
                    buttonWidth: 120,
                    buttonShape: const LiquidRoundedRectangle(borderRadius: 64),
                    items: FocusSceneRenderMode.values.map((mode) {
                      final isSelected = settings.focusSceneRenderMode == mode;
                      return GlassMenuItem(
                        title: mode.label,
                        icon: Icon(
                          isSelected ? Icons.check_rounded : null,
                          size: 20,
                        ),
                        isSelected: isSelected,
                        onTap: () {
                          ref
                              .read(appSettingsNotifierProvider.notifier)
                              .setFocusSceneRenderMode(mode);
                        },
                      );
                    }).toList(),
                  ),
                ),
                SettingsTile(
                  title: Text('场景渲染质量'),
                  trailing: GlassPullDownButton(
                    label: settings.focusSceneRenderQuality.label,
                    buttonWidth: 120,
                    buttonShape: const LiquidRoundedRectangle(borderRadius: 64),
                    items: FocusSceneRenderQuality.values.map((quality) {
                      final isSelected =
                          settings.focusSceneRenderQuality == quality;
                      return GlassMenuItem(
                        title: quality.label,
                        icon: Icon(
                          isSelected ? Icons.check_rounded : null,
                          size: 20,
                        ),
                        isSelected: isSelected,
                        onTap: () {
                          ref
                              .read(appSettingsNotifierProvider.notifier)
                              .setFocusSceneRenderQuality(quality);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
