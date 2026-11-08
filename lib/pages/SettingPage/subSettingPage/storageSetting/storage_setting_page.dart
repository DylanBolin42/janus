import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:janus/providers/database_provider.dart';
import 'package:janus/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/models/app_settings.dart';
import 'package:janus/providers/settings_provider.dart';
import 'package:janus/theme/theme.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:janus/shared/custom_appbar.dart';
import 'package:janus/shared/custom_app_settings_tile.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class StorageSettingPage extends ConsumerStatefulWidget {
  const StorageSettingPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StorageSettingPageState();
}

class _StorageSettingPageState extends ConsumerState<StorageSettingPage> {
  Future<({int tasks, int tags})>? _statistics;

  Future<void> _clear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除全部任务和标签？'),
        content: const Text('将删除全部任务和标签，应用设置会保留。下一步需要再次确认。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final finalConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('最后确认：永久删除'),
        content: const Text('尚无备份或撤销功能。全部任务和标签将永久丢失，无法恢复。确定继续？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('永久删除'),
          ),
        ],
      ),
    );
    if (finalConfirmed != true || !mounted) return;
    try {
      final service = StorageService(ref.read(appDatabaseProvider));
      await service.clear();
      if (!mounted) return;
      setState(() {
        _statistics = service.statistics();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('任务和标签已删除')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('删除失败，请重试')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings =
        ref.watch(appSettingsProvider).value ?? const AppSettings();
    // TODO(JANUS-15): 本地训练模型尚不存在，useLogToTrain 目前仅保存偏好。
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      body: GlassScaffold(
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
                        // TODO(JANUS-15): 跨平台数据库文件大小需平台文件 API，先显示实际记录数。
                        FutureBuilder<({int tasks, int tags})>(
                          future: _statistics ??= StorageService(
                            ref.read(appDatabaseProvider),
                          ).statistics(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return TextButton(
                                onPressed: () =>
                                    setState(() => _statistics = null),
                                child: const Text('读取失败，点击重试'),
                              );
                            }
                            final data = snapshot.data;
                            return Text(
                              data == null
                                  ? '读取中…'
                                  : '任务：${data.tasks}，标签：${data.tags}',
                            );
                          },
                        ),
                      ],
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
                    // TODO(JANUS-15): 缺少备份格式定义、文件选择与迁移校验服务。
                    description: Text('导入服务尚未接入'),
                  ),
                  SettingsTile.navigation(
                    title: Text('导出数据库'),
                    leading: Icon(MdiIcons.export),
                    trailing: Icon(Icons.navigate_next_rounded),
                    // TODO(JANUS-15): 缺少备份格式及跨平台文件导出服务。
                    description: Text('导出服务尚未接入'),
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
                    onTap: (_) => _clear(),
                  ),
                ],
              ),
              SettingsSection(
                title: Text('日志', style: tt.titleMedium),
                tiles: [
                  SettingsTile(
                    title: Text('本地模型训练'),
                    description: Text('当前仅保存偏好，本地训练服务尚未接入'),
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
      ),
    );
  }
}
