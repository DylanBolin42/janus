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
        ref.watch(appSettingsNotifierProvider).valueOrNull ??
        const AppSettings();
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
                  leading: Icon(Icons.notifications_rounded),
                  trailing: GlassSwitch(
                    value: settings.isNotificationEnabled,
                    onChanged: (status) {
                      ref
                          .read(appSettingsNotifierProvider.notifier)
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
                    buttonWidth: 120,
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
                              .read(appSettingsNotifierProvider.notifier)
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
                    buttonWidth: 120,
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
                              .read(appSettingsNotifierProvider.notifier)
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
                  ), //TODO: 这里需要绑定时间
                ),
                SettingsTile(
                  title: Text('晚上发送时间'),
                  trailing: CupertinoTimePickerButton(
                    use24hFormat: true,
                  ), //TODO: 这里需要绑定时间
                ),
              ],
            ),
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
