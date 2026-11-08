import 'dart:io';
import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:janus/providers/database_provider.dart';
import 'package:janus/services/storage_service.dart';
import 'package:janus/services/storage_file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/models/app_settings.dart';
import 'package:janus/providers/settings_provider.dart';
import 'package:janus/theme/theme.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:janus/shared/custom_appbar.dart';
import 'package:janus/shared/custom_app_settings_tile.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class StorageSettingPage extends ConsumerStatefulWidget {
  const StorageSettingPage({super.key, this.filePicker});

  final StorageFilePicker? filePicker;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StorageSettingPageState();
}

class _StorageSettingPageState extends ConsumerState<StorageSettingPage> {
  Future<StorageStatistics>? _statistics;
  bool _busy = false;

  StorageService get _service => StorageService(ref.read(appDatabaseProvider));

  void _feedback(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _operate(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) setState(() => _statistics = null);
    } on StorageFileException catch (error) {
      _feedback(error.message);
    } on FormatException catch (error) {
      _feedback(error.message);
    } on FileSystemException {
      _feedback('文件读写失败，请检查文件是否存在及目录访问权限');
    } catch (_) {
      _feedback('操作失败，现有数据已保留，请重试');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _export() => _operate(() async {
    final destination = await _transfer.exportToPicker();
    if (destination == null) {
      _feedback('已取消保存到所选位置；应用内快照已保留');
      return;
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('快照已导出'),
        content: SelectableText('已保存至：\n$destination\n应用内也保留了快照，应用设置不包含在内。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  });

  StorageTransfer get _transfer =>
      StorageTransfer(_service, widget.filePicker ?? NativeStorageFilePicker());

  Future<void> _import() => _operate(() async {
    final snapshot = await _transfer.selectSnapshot();
    if (snapshot == null) {
      _feedback('已取消选择文件，现有数据未修改');
      return;
    }
    await _confirmImport(snapshot);
  });

  Future<void> _importLocal() => _operate(() async {
    final files = await _service.snapshots();
    if (!mounted) return;
    final selected = await showDialog<File>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('选择本地 JSON 快照'),
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('选择应用内保留的快照；外部文件可使用“导入数据库”的系统文件选择器。'),
          ),
          if (files.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('暂无快照，请先导出。'),
            ),
          for (final file in files)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, file),
              child: Text(file.uri.pathSegments.last),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
    if (selected == null) return;
    final snapshot = await _service.readSnapshot(selected);
    await _confirmImport(snapshot);
  });

  Future<void> _confirmImport(StorageSnapshot snapshot) async {
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('替换全部任务和标签？'),
        content: Text(
          '快照包含 ${snapshot.tasks.length} 个任务、${snapshot.tags.length} 个标签。当前数据将被替换，无法撤销；应用设置保留。建议先导出当前数据。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认导入'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _service.restore(snapshot);
    _feedback('快照已导入');
  }

  Future<void> _clear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除全部任务和标签？'),
        content: const Text('此操作无法撤销，应用设置会保留。'),
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

                        FutureBuilder<StorageStatistics>(
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
                                  : '任务：${data.tasks}，标签：${data.tags}，已完成：${data.completed}\n数据库文件（含 WAL/SHM）：${data.bytes == null ? "不可用" : "${data.bytes} 字节"}',
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
                    description: Text('选择任意位置的 JSON 文件，校验并确认后导入'),
                    onPressed: _busy ? null : (_) => _import(),
                  ),
                  SettingsTile.navigation(
                    title: Text('导出数据库'),
                    leading: Icon(MdiIcons.export),
                    trailing: Icon(Icons.navigate_next_rounded),
                    description: Text('选择保存位置；本地最多 10 份 / 100 MiB，自动清理最旧副本'),
                    onPressed: _busy ? null : (_) => _export(),
                  ),
                  SettingsTile.navigation(
                    title: Text('应用内快照'),
                    leading: Icon(Icons.history),
                    description: Text('从本应用保留的快照恢复（导出时自动清理最旧副本）'),
                    onPressed: _busy ? null : (_) => _importLocal(),
                  ),
                  CustomAppSettingsTile(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.errorContainer,
                    onTap: _busy ? null : (_) => _operate(_clear),
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
