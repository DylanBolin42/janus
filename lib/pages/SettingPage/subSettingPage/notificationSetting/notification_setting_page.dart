import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:janus/models/app_settings.dart';
import 'package:janus/providers/settings_provider.dart';
import 'package:janus/providers/notification_provider.dart';
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
    final notificationStatus = ref.watch(notificationSyncProvider);
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
                  description: Text(
                    !settings.isNotificationEnabled
                        ? '通知已关闭'
                        : notificationStatus.when(
                            data: (allowed) => allowed
                                ? '已获系统授权；实际投递受系统限制'
                                : '未获系统通知授权或当前平台不支持',
                            loading: () => '正在检查系统通知权限…',
                            error: (_, _) => '通知调度失败，请重试或检查系统设置',
                          ),
                  ),
                  leading: Icon(Icons.notifications_rounded),
                  trailing: GlassSwitch(
                    value: settings.isNotificationEnabled,
                    onChanged: (status) async {
                      if (status) {
                        try {
                          final allowed = await ref
                              .read(notificationServiceProvider)
                              .platform
                              .permission(request: true);
                          if (!context.mounted) return;
                          if (!allowed) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('未获通知权限，请在系统设置中允许通知'),
                              ),
                            );
                            return;
                          }
                        } catch (_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('无法启用通知，请稍后重试')),
                          );
                          return;
                        }
                      }
                      if (!context.mounted) return;
                      ref
                          .read(appSettingsProvider.notifier)
                          .setNotificationEnabled(status);
                    },
                  ),
                ),
              ],
            ),
            SettingsSection(
              title: Text('通知强度（全屏选项暂按横幅投递）', style: tt.titleMedium),
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
