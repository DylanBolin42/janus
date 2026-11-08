import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:janus/models/app_settings.dart';
import 'package:janus/providers/settings_provider.dart';
import 'package:janus/shared/custom_appbar.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';

class NotificationSettingPage extends ConsumerStatefulWidget {
  const NotificationSettingPage({super.key});

  @override
  ConsumerState<NotificationSettingPage> createState() =>
      _NotificationSettingPageState();
}

class _NotificationSettingPageState
    extends ConsumerState<NotificationSettingPage> {
  @override
  Widget build(BuildContext context) {
    final settings =
        ref.watch(appSettingsProvider).value ?? const AppSettings();
    final tt = Theme.of(context).textTheme;

    return GlassScaffold(
      topEdgeFade: false,
      appBar: const CustomAppbar(title: '通知', showBack: true),
      body: CustomAppbar.wrapBody(
        context,
        SettingsList(
          sections: [
            SettingsSection(
              tiles: [
                SettingsTile(
                  title: Text('是否通知'),
                  description: const Text('当前仅保存偏好，系统通知服务尚未接入'),
                  leading: Icon(Icons.notifications_rounded),
                  trailing: GlassSwitch(
                    value: settings.isNotificationEnabled,
                    onChanged: (status) {
                      ref
                          .read(appSettingsProvider.notifier)
                          .setNotificationEnabled(status);
                    },
                  ),
                ),
              ],
            ),
            SettingsSection(
              title: Text('通知强度', style: tt.titleMedium),
              tiles: [
                SettingsTile(
                  title: Text('紧迫通知方式'),
                  trailing: GlassPullDownButton(
                    icon: Icon(settings.urgentNotificationStyle.icon),
                    label: settings.urgentNotificationStyle.label,
                    buttonWidth: 160,
                    buttonShape: const LiquidRoundedRectangle(borderRadius: 64),
                    items: UrgentNotificationStyle.values.map((mode) {
                      final isSelected =
                          settings.urgentNotificationStyle == mode;
                      return GlassMenuItem(
                        title: mode.label,
                        icon: Icon(
                          isSelected ? Icons.check_rounded : mode.icon,
                          size: 20,
                        ),
                        isSelected: isSelected,
                        onTap: () {
                          ref
                              .read(appSettingsProvider.notifier)
                              .setUrgentNotificationStyle(mode);
                        },
                      );
                    }).toList(),
                  ),
                ),
                SettingsTile(
                  title: Text('临近通知方式'),
                  trailing: GlassPullDownButton(
                    icon: Icon(settings.approachingNotificationStyle.icon),
                    label: settings.approachingNotificationStyle.label,
                    buttonWidth: 160,
                    buttonShape: const LiquidRoundedRectangle(borderRadius: 64),
                    items: ApproachingNotificationStyle.values.map((mode) {
                      final isSelected =
                          settings.approachingNotificationStyle == mode;
                      return GlassMenuItem(
                        title: mode.label,
                        icon: Icon(
                          isSelected ? Icons.check_rounded : mode.icon,
                          size: 20,
                        ),
                        isSelected: isSelected,
                        onTap: () {
                          ref
                              .read(appSettingsProvider.notifier)
                              .setApproachingNotificationStyle(mode);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            SettingsSection(
              title: Text('每日简报', style: tt.titleMedium),
              tiles: [
                SettingsTile(
                  title: Text('早晨发送时间'),
                  trailing: CupertinoTimePickerButton(
                    use24hFormat: true,
                    initialTime: settings.morningBriefingTime,
                    onCompleted: (time) {
                      if (time != null) {
                        ref
                            .read(appSettingsProvider.notifier)
                            .setMorningBriefingTime(time);
                      }
                    },
                  ),
                ),
                SettingsTile(
                  title: Text('晚上发送时间'),
                  trailing: CupertinoTimePickerButton(
                    use24hFormat: true,
                    initialTime: settings.eveningBriefingTime,
                    onCompleted: (time) {
                      if (time != null) {
                        ref
                            .read(appSettingsProvider.notifier)
                            .setEveningBriefingTime(time);
                      }
                    },
                  ),
                ),
              ],
            ),
            // TODO(JANUS-15): 接入平台通知权限、调度及简报生成服务后消费上述配置。
            // 当前仓库没有通知触发服务，保存配置不会产生系统通知。
            SettingsSection(
              tiles: [SettingsTile(title: Text('🚧开发中🚧'))],
              title: Text('通知音效', style: tt.titleMedium),
            ),
          ],
        ),
      ),
    );
  }
}
