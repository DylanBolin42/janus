import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/models/app_settings.dart';
import 'package:janus/providers/settings_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:janus/theme/theme.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:janus/shared/custom_app_settings_tile.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class StorageSettingPage extends ConsumerStatefulWidget {
  const StorageSettingPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StorageSettingPageState();
}

class _StorageSettingPageState extends ConsumerState<StorageSettingPage> {
  final GlassLargeTitleController _titleController =
      GlassLargeTitleController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings =
        ref.watch(appSettingsProvider).value ?? const AppSettings();
    final tt = Theme.of(context).textTheme;
    return GlassScaffold(
      appBar: GlassAppBar.pinned(
        title: const Text('存储'),
        largeTitleController: _titleController,
        onBack: () => context.pop(),
      ),
      body: CustomScrollView(
        controller: _titleController.scrollController,
        slivers: [
          GlassLargeTitle(text: '存储', controller: _titleController),
          SliverToBoxAdapter(
            child: SettingsList(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
                  title: Text('数据库操作', style: tt.titleMedium),
                  tiles: [
                    SettingsTile.navigation(
                      title: Text('导入数据库'),
                      leading: Icon(MdiIcons.import),
                      trailing: Icon(Icons.navigate_next_rounded),
                      description: Text('导入兼容格式的数据库'),
                    ),
                    SettingsTile.navigation(
                      title: Text('导出数据库'),
                      leading: Icon(MdiIcons.export),
                      trailing: Icon(Icons.navigate_next_rounded),
                      description: Text('导出特定格式的数据库为某些格式'),
                    ),
                    CustomAppSettingsTile(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.errorContainer,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete_forever_rounded),
                            SizedBox(width: AppSpacing.base),
                            Text(
                              '删除数据库',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: (_) {},
                    ),
                  ],
                ),
                SettingsSection(
                  title: Text('日志', style: tt.titleMedium),
                  tiles: [
                    SettingsTile(
                      title: Text('本地模型训练'),
                      description: Text('是否允许用于本地小型神经网络训练？'),
                      trailing: GlassSwitch(
                        value: settings.useLogToTrain,
                        onChanged: (status) {
                          ref
                              .read(appSettingsProvider.notifier)
                              .setUseLogToTrain(status);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
