import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/models/app_settings.dart';
import 'package:janus/providers/settings_provider.dart';
import 'package:janus/shared/custom_app_settings_tile.dart';
import 'package:janus/shared/custom_appbar.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:janus/shared/flex_setting_section.dart';
import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';

class SyncSettingPage extends ConsumerStatefulWidget {
  const SyncSettingPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SyncSettingPageState();
}

class _SyncSettingPageState extends ConsumerState<SyncSettingPage> {
  final _webdavUrlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _syncToController = TextEditingController();
  final _encryptPasswordController = TextEditingController();

  @override
  void dispose() {
    _webdavUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _syncToController.dispose();
    _encryptPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings =
        ref.watch(appSettingsNotifierProvider).valueOrNull ??
        const AppSettings();
    return GlassScaffold(
      topEdgeFade: false,
      appBar: const CustomAppbar(title: '同步', showBack: true),
      body: CustomAppbar.wrapBody(
        context,
        SettingsList(
          sections: [
            SettingsSection(
              tiles: [
                CustomAppSettingsTile(
                  child: Row(
                    children: [
                      Icon(Icons.update_rounded),
                      Spacer(),
                      Text('当前消耗流量：0.5GB'),
                    ],
                  ),
                ),
                InteractiveTile(
                  title: Text('是否同步'),
                  leading: Icon(Icons.upload_rounded),
                  trailing: GlassSwitch(
                    value: settings.syncEnabled,
                    onChanged: (val) {
                      ref
                          .read(appSettingsNotifierProvider.notifier)
                          .setSyncEnabled(val);
                    },
                  ),
                ),
              ],
            ),
            SettingsSection(
              title: Text('同步设置'),
              tiles: [
                InteractiveTile(
                  title: Text('WEBDAV地址'),
                  trailing: SizedBox(
                    width: 200,
                    child: GlassTextField(
                      controller: _webdavUrlController,
                      shape: LiquidRoundedSuperellipse(borderRadius: 64),
                    ),
                  ),
                ),
                InteractiveTile(
                  title: Text('用户名'),
                  trailing: SizedBox(
                    width: 200,
                    child: GlassTextField(
                      controller: _usernameController,
                      shape: LiquidRoundedSuperellipse(borderRadius: 64),
                    ),
                  ),
                ),
                InteractiveTile(
                  title: Text('密码'),
                  trailing: SizedBox(
                    width: 200,
                    child: GlassTextField(
                      controller: _passwordController,
                      obscureText: true,
                      shape: LiquidRoundedSuperellipse(borderRadius: 64),
                    ),
                  ),
                ),
                InteractiveTile(
                  title: Text('同步至'),
                  trailing: SizedBox(
                    width: 200,
                    child: GlassTextField(
                      controller: _syncToController,
                      shape: LiquidRoundedSuperellipse(borderRadius: 64),
                    ),
                  ),
                ),
                InteractiveTile(
                  title: Text('同步模式'),
                  trailing: Builder(
                    builder: (ctx) => GlassPullDownButton(
                      label: settings.syncMode.label,
                      buttonWidth: 120,
                      buttonShape: const LiquidRoundedRectangle(
                        borderRadius: 64,
                      ),
                      items: SyncMode.values.map((mode) {
                        final isSelected = settings.syncMode == mode;
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
                                .setSyncMode(mode);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            FlexSettingSection(
              title: Text('手动操作'),
              tiles: [
                FlexRow(
                  children: [
                    FlexTile(child: Center(child: Text('手动上传'))),
                    FlexTile(child: Center(child: Text('手动下载'))),
                  ],
                ),
                FlexTile(child: Center(child: Text('连通性检查'))),
              ],
            ),
            SettingsSection(
              title: Text('同步行为'),
              tiles: [
                InteractiveTile(
                  title: Text('触发间隔'),
                  trailing: Builder(
                    builder: (ctx) => GlassPullDownButton(
                      icon: Icon(settings.syncTrigger.icon),
                      label: settings.syncTrigger.label,
                      buttonWidth: 120,
                      buttonShape: const LiquidRoundedRectangle(
                        borderRadius: 64,
                      ),
                      items: SyncTrigger.values.map((trigger) {
                        final isSelected = settings.syncTrigger == trigger;
                        return GlassMenuItem(
                          title: trigger.label,
                          icon: Icon(
                            isSelected ? Icons.check_rounded : trigger.icon,
                            size: 20,
                          ),
                          isSelected: isSelected,
                          onTap: () {
                            ref
                                .read(appSettingsNotifierProvider.notifier)
                                .setSyncTrigger(trigger);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
                switch (settings.syncTrigger) {
                  SyncTrigger.onChanged => InteractiveTile(
                    leading: Icon(Icons.save_rounded),
                    title: Text('自动保存'),
                    description: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: 'Janus会在新增、修改、删除任务时触发同步，'),
                          TextSpan(
                            text: '不建议有上传次数限额的用户使用该模式',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SyncTrigger.onInterval => InteractiveTile(
                    leading: Icon(Icons.more_time_rounded),
                    title: Text('间隔时长'),
                    description: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: 'Janus将会在特定时长后触发同步（无数据变化则不进行同步操作），'),
                          TextSpan(
                            text: '建议酌情设定间隔时长',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    trailing: CupertinoTimePickerButton(
                      initialTime: TimeOfDay.fromDateTime(
                        DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now()
                              .day, //INFO: Wasted data, won't be stored into the [DataBase] or [SharedPreference]. Only to meet the need of a [DateTime] type data.
                          //WARNING: Unsure whether it will cause vulnerability.
                        ).add(settings.syncDurationOnInterval),
                      ),
                      onCompleted: (timeOfDay) {
                        ref
                            .read(appSettingsNotifierProvider.notifier)
                            .setSyncDurationOnInterval(
                              Duration(
                                hours: timeOfDay!.hour,
                                minutes: timeOfDay.minute,
                              ),
                            );
                      },
                    ),
                  ),

                  SyncTrigger.onTime => InteractiveTile(
                    leading: Icon(Icons.av_timer_rounded),
                    title: Text('上传时间点'),
                    description: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: 'Janus将在特定时间点触发同步（无数据变化则不进行同步操作），'),
                          TextSpan(
                            text: '可能会导致多端数据不同步，不建议日程不规律的用户使用该模式',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                },
              ],
            ),
            SettingsSection(
              title: Text('安全'),
              tiles: [
                InteractiveTile(
                  leading: Icon(Icons.security_rounded),
                  title: Text('安全性说明'),
                  description: Text(
                    '虽然数据传输过程中信息将会根据传输协议加密，但如不开启数据加密，云端WEBDAV服务器中用户数据将以明文存储，若云端WEBDAV服务器发生数据泄露，将无法保证用户个人信息的安全性。',
                  ),
                ),
                InteractiveTile(
                  title: Text('加密算法'),
                  description: Text(
                    '更长的密钥长度会带来更高安全性，但是编解码速度相应也会减慢。一般使用RSA-2048即可',
                  ),
                  trailing: Builder(
                    builder: (ctx) => GlassPullDownButton(
                      icon: null,
                      label: settings.rsaType.label,
                      buttonWidth: 170,
                      buttonShape: const LiquidRoundedRectangle(
                        borderRadius: 64,
                      ),
                      items: RsaType.values.map((type) {
                        final isSelected = settings.rsaType == type;
                        return GlassMenuItem(
                          title: type.label,
                          icon: Icon(
                            isSelected ? Icons.check_rounded : null,
                            size: 20,
                          ),
                          isSelected: isSelected,
                          onTap: () {
                            ref
                                .read(appSettingsNotifierProvider.notifier)
                                .setRsaType(type);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
                InteractiveTile(
                  title: Text('密码'),
                  description: Text.rich(
                    TextSpan(
                      //TODO: 将颜色设为和其他一致
                      children: [
                        const TextSpan(text: '建议设置8-16位混合密码以提高安全性。'),
                        const TextSpan(
                          text: '一旦设定将无法找回，请务必妥善保管！',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  trailing: SizedBox(
                    width: 200,
                    child: GlassTextField(
                      controller: _encryptPasswordController,
                      obscureText: true,
                      shape: LiquidRoundedSuperellipse(borderRadius: 64),
                    ),
                  ),
                ),
                InteractiveTile(
                  title: Text('应用锁'),
                  trailing: GlassSwitch(
                    value: settings.useAppLock,
                    onChanged: (status) {
                      ref
                          .read(appSettingsNotifierProvider.notifier)
                          .setUseAppLock(status);
                    },
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
