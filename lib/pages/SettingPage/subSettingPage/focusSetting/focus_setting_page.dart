import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/models/app_settings.dart';
import 'package:janus/providers/settings_provider.dart';
import 'package:janus/shared/custom_appbar.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class FocusSettingPage extends ConsumerStatefulWidget {
  const FocusSettingPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FocusSettingPageState();
}

class _FocusSettingPageState extends ConsumerState<FocusSettingPage> {
  @override
  Widget build(BuildContext context) {
    final settings =
        ref.watch(appSettingsProvider).value ?? const AppSettings();
    // TODO(JANUS-15): 专注引擎尚未实现，暂离限制和渲染配置待引擎消费。
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: GlassScaffold(
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
                    description: const Text('当前仅保存偏好，专注计时器尚未接入'),
                    trailing: SizedBox(
                      width: 220,
                      child: GlassSegmentedControl(
                        onSegmentSelected: (index) {
                          ref
                              .read(appSettingsProvider.notifier)
                              .setFocusTimerMode(FocusTimerMode.values[index]);
                        },
                        selectedIndex: settings.focusTimerMode.index,
                        segments: [
                          GlassSegment(label: '倒计时'),
                          GlassSegment(label: '正计时'),
                          GlassSegment(label: '番茄钟'),
                        ],
                      ),
                    ), // TODO(JANUS-15): 专注计时页尚为 Placeholder；计时器实现后消费默认模式。
                  ),
                ],
              ),
              SettingsSection(
                title: Text('行为', style: tt.titleMedium),
                tiles: [
                  SettingsTile(
                    title: Text('自动DND'),
                    trailing: GlassSwitch(
                      value: false,
                      onChanged: (_) =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('系统专注权限服务尚未接入')),
                          ),
                    ),
                  ), // TODO(JANUS-15): 需平台 DND/通知管理权限及服务，暂不启用。
                  SettingsTile(
                    title: Text('通知折叠'),
                    trailing: GlassSwitch(
                      value: false,
                      onChanged: (_) =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('系统专注权限服务尚未接入')),
                          ),
                    ),
                  ), // TODO(JANUS-15): 需平台 DND/通知管理权限及服务，暂不启用。
                  SettingsTile.navigation(
                    title: Text('应用白名单'),
                    trailing: Icon(Icons.navigate_next_rounded),
                    description: Text(
                      '可以在专注过程中正常访问，推荐不要把流媒体平台、游戏等易打断专注的软件加入白名单',
                    ), // TODO(JANUS-15): 需应用枚举和无障碍服务后实现白名单页面。
                  ),
                ],
              ),
              SettingsSection(
                title: Text('暂离', style: tt.titleMedium),
                tiles: [
                  SettingsTile(
                    title: Text('单次暂离时长'),
                    trailing: GlassPullDownButton(
                      label: settings.tempLeaveDuration.label,
                      buttonWidth: 120,
                      buttonShape: const LiquidRoundedRectangle(
                        borderRadius: 64,
                      ),
                      items: TempLeaveDuration.values.map((duration) {
                        final isSelected =
                            settings.tempLeaveDuration == duration;
                        return GlassMenuItem(
                          title: duration.label,
                          icon: Icon(
                            isSelected ? Icons.check_rounded : null,
                            size: 20,
                          ),
                          isSelected: isSelected,
                          onTap: () {
                            ref
                                .read(appSettingsProvider.notifier)
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
                      buttonShape: const LiquidRoundedRectangle(
                        borderRadius: 64,
                      ),
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
                                .read(appSettingsProvider.notifier)
                                .setTempLeaveTimes(times);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              SettingsSection(
                title: Text('场景', style: tt.titleMedium),
                tiles: [
                  SettingsTile(
                    title: Text('场景渲染引擎'),
                    trailing: GlassPullDownButton(
                      //TODO: 添加渲染引擎描述和建议
                      // TODO: 可以适当添加商标icon
                      label: settings.focusSceneRenderMode.label,
                      buttonWidth: 120,
                      buttonShape: const LiquidRoundedRectangle(
                        borderRadius: 64,
                      ),
                      items: FocusSceneRenderMode.values.map((mode) {
                        final isSelected =
                            settings.focusSceneRenderMode == mode;
                        return GlassMenuItem(
                          title: mode.label,
                          icon: Icon(
                            isSelected ? Icons.check_rounded : null,
                            size: 20,
                          ),
                          isSelected: isSelected,
                          onTap: () {
                            ref
                                .read(appSettingsProvider.notifier)
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
                      buttonShape: const LiquidRoundedRectangle(
                        borderRadius: 64,
                      ),
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
                                .read(appSettingsProvider.notifier)
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
      ),
    );
  }
}
