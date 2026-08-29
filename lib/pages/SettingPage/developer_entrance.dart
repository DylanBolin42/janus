/// 这是为开发者搭建的快速调试和数据注入文件，在发行版中不应以任何形式引用或使用

import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/providers/database_provider.dart';
import 'package:janus/services/logger_service.dart';
import 'package:janus/shared/custom_appbar.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class DeveloperEntrance extends ConsumerStatefulWidget {
  const DeveloperEntrance({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DeveloperEntranceState();
}

class _DeveloperEntranceState extends ConsumerState<DeveloperEntrance> {
  /// 正在执行数据库操作，防止连点
  bool _busy = false;

  /// 填充示例数据
  Future<void> _fillSampleData() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(taskDaoProvider).seedSampleData();
    } catch (e, stack) {
      AppLogger.e('填充示例数据失败', error: e, stackTrace: stack);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// 清空全部数据
  Future<void> _deleteAllData() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(taskDaoProvider).deleteAllData();
      if (!mounted) return;
      GlassToast.show(
        context,
        position: GlassToastPosition.top,

        message: '已清空全部数据',
        type: GlassToastType.success,
      );
    } catch (e, stack) {
      AppLogger.e('删除所有数据失败', error: e, stackTrace: stack);
      if (!mounted) return;
      GlassToast.show(
        context,
        position: GlassToastPosition.top,
        message: '删除数据失败，请重试',
        type: GlassToastType.error,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      edgeFade: false,
      appBar: CustomAppbar(title: 'Hello, Developer', showBack: true),
      body: CustomAppbar.wrapBody(
        context,
        SettingsList(
          sections: [
            SettingsSection(
              title: Text('数据库操作'),
              tiles: [
                SettingsTile(
                  title: Text('填充示例数据'),
                  trailing: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  onPressed: _busy ? null : (_) => _fillSampleData(),
                ),
                SettingsTile(
                  title: Text('删除所有数据'),
                  onPressed: _busy ? null : (_) => _deleteAllData(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
