import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/models/app_settings.dart';
import 'package:janus/providers/settings_provider.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/widgets/surfaces/glass_scaffold.dart';
import 'package:janus/shared/custom_appbar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:janus/shared/custom_app_settings_tile.dart';

class StorageSettingPage extends ConsumerStatefulWidget {
  const StorageSettingPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StorageSettingPageState();
}

class _StorageSettingPageState extends ConsumerState<StorageSettingPage> {
  late final settings =
      ref.watch(appSettingsNotifierProvider).valueOrNull ?? const AppSettings();
  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      topEdgeFade: false,
      appBar: const CustomAppbar(title: '存储', showBack: true),
      body: CustomAppbar.wrapBody(
        context,
        SettingsList(
          sections: [
            SettingsSection(
              tiles: [
                CustomAppSettingsTile(
                  child: Column(
                    children: [
                      Text('当前存储占用'),
                      SizedBox(height: 60),
                    ], //TODO:补充显示逻辑
                  ),
                ),
              ],
            ),
            SettingsSection(
              title: Text('数据库操作'),
              tiles: [
                SettingsTile.navigation(
                  title: Text('导入数据库'),
                  leading: FaIcon(FontAwesomeIcons.fileImport),
                  description: Text('导入兼容格式的数据库'),
                ),
                SettingsTile.navigation(
                  title: Text('导出数据库'),
                  leading: FaIcon(FontAwesomeIcons.fileExport),
                  description: Text('导出特定格式的数据库为某些格式'),
                ),
                CustomAppSettingsTile(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  child: Center(
                    child: Text(
                      '删除数据库',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  onTap: (_) {},
                ),
              ],
            ),
            SettingsSection(
              title: Text('日志'),
              tiles: [
                SettingsTile(
                  title: Text('本地模型训练'),
                  description: Text('是否允许用于本地小型神经网络训练？'),
                  trailing: GlassSwitch(
                    value: settings.useLogToTrain,
                    onChanged: (status) {
                      ref
                          .read(appSettingsNotifierProvider.notifier)
                          .setUseLogToTrain(status);
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
