import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/models/app_settings.dart';
import 'package:janus/providers/settings_provider.dart';
import 'package:janus/shared/custom_app_settings_tile.dart';
import 'package:janus/shared/custom_appbar.dart';
import 'package:janus/theme/theme.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';

class PlanningSettingPage extends ConsumerStatefulWidget {
  const PlanningSettingPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PlanningSettingPageState();
}

class _PlanningSettingPageState extends ConsumerState<PlanningSettingPage> {
  @override
  Widget build(BuildContext context) {
    final settings =
        ref.watch(appSettingsNotifierProvider).valueOrNull ??
        const AppSettings();
    final tt = Theme.of(context).textTheme;
    return GlassScaffold(
      topEdgeFade: false,
      appBar: const CustomAppbar(title: '规划', showBack: true),
      body: CustomAppbar.wrapBody(
        context,
        SettingsList(
          sections: [
            SettingsSection(
              title: Text('工作周期', style: tt.titleMedium),
              tiles: [
                SettingsTile(
                  title: Text('工作时间段'),
                  leading: Icon(Icons.work_history_rounded),
                  trailing: Row(
                    children: [
                      CupertinoTimePickerButton(),
                      SizedBox(width: AppSpacing.base),
                      CupertinoTimePickerButton(),
                    ],
                  ),
                ),
                SettingsTile(
                  title: Text('午休时间段'),
                  leading: Icon(Icons.breakfast_dining_rounded),
                  trailing: Row(
                    children: [
                      CupertinoTimePickerButton(),
                      SizedBox(width: AppSpacing.base),
                      CupertinoTimePickerButton(),
                    ],
                  ),
                ),
              ],
            ),
            SettingsSection(
              title: Text('任务密度', style: tt.titleMedium),
              tiles: [
                SettingsTile(
                  title: Text(
                    '分级说明',
                  ), //TODO: 添加说明description的默认颜色（浅灰，与SettingTile保持一致）
                  description: RichText(
                    text: TextSpan(
                      text: '宽松-每天占用60%的工作时间\n',
                      children: [
                        TextSpan(text: '中等-每天占用80%的工作时间\n'),
                        TextSpan(text: '密集-每天占用95%的工作时间\n'),
                        TextSpan(
                          text:
                              '额外说明：任务密度约大，单位时间内能完成的任务数量更多，但也要求用户有更高的效率，同时容错率也更低，请用户理性选择。',
                        ),
                      ],
                    ),
                  ),
                ),
                SettingsTile(
                  title: Text('工作日'),
                  trailing: GlassPullDownButton(
                    label: settings.workingDayTaskDensity.label,
                    buttonWidth: 120,
                    buttonShape: const LiquidRoundedRectangle(borderRadius: 64),
                    items: WorkingDayTaskDensity.values.map((density) {
                      final isSelected =
                          settings.workingDayTaskDensity == density;
                      return GlassMenuItem(
                        title: density.label,
                        icon: Icon(
                          isSelected ? Icons.check_rounded : null,
                          size: 20,
                        ),
                        isSelected: isSelected,
                        onTap: () {
                          ref
                              .read(appSettingsNotifierProvider.notifier)
                              .setWorkingDayTaskDensity(density);
                        },
                      );
                    }).toList(),
                  ),
                ),
                SettingsTile(
                  title: Text('休息日'),
                  trailing: GlassPullDownButton(
                    label: settings.restDayTaskDensity.label,
                    buttonWidth: 120,
                    buttonShape: const LiquidRoundedRectangle(borderRadius: 64),
                    items: RestDayTaskDensity.values.map((density) {
                      final isSelected = settings.restDayTaskDensity == density;
                      return GlassMenuItem(
                        title: density.label,
                        icon: Icon(
                          isSelected ? Icons.check_rounded : null,
                          size: 20,
                        ),
                        isSelected: isSelected,
                        onTap: () {
                          ref
                              .read(appSettingsNotifierProvider.notifier)
                              .setRestDayTaskDensity(density);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            SettingsSection(
              title: Text('规划跨度', style: tt.titleMedium),

              tiles: [
                SettingsTile(
                  title: Text('跨度'),
                  description: Text('规划跨度越长，安排越详细，但用户需要更提前输入足够多的日程以供计算。'),
                  trailing: GlassPullDownButton(
                    label: settings.planningHorizon.label,
                    buttonWidth: 120,
                    buttonShape: const LiquidRoundedRectangle(borderRadius: 64),
                    items: PlanningHorizon.values.map((horizon) {
                      final isSelected = settings.planningHorizon == horizon;
                      return GlassMenuItem(
                        title: horizon.label,
                        icon: Icon(
                          isSelected ? Icons.check_rounded : null,
                          size: 20,
                        ),
                        isSelected: isSelected,
                        onTap: () {
                          ref
                              .read(appSettingsNotifierProvider.notifier)
                              .setPlanningHorizon(horizon);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            SettingsSection(
              title: Text('优先级判断', style: tt.titleMedium),
              tiles: [
                CustomAppSettingsTile(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_rounded),
                          SizedBox(width: AppSpacing.base),
                          Text(
                            '警告',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onErrorContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.base),
                      Text(
                        '以下设置项为算法核心配置，非专业人士请勿随意修改！',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                SettingsTile.navigation(
                  title: Text('紧急'),
                  leading: Icon(Icons.warning_rounded),
                  trailing: Icon(Icons.navigate_next_rounded),
                ),
                SettingsTile.navigation(
                  title: Text('迫近'),
                  leading: Icon(Icons.hourglass_bottom_rounded),
                  trailing: Icon(Icons.navigate_next_rounded),
                ),
                SettingsTile.navigation(
                  title: Text('规划'),
                  leading: Icon(Icons.event_note_rounded),
                  trailing: Icon(Icons.navigate_next_rounded),
                ),
                SettingsTile.navigation(
                  title: Text('提前'),
                  leading: Icon(Icons.rocket_launch_rounded),
                  trailing: Icon(Icons.navigate_next_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
