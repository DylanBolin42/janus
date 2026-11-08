import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/providers/settings_provider.dart';

/// Visible across routes so startup recovery cannot silently discard preferences.
class SettingsRecoveryNotice extends ConsumerWidget {
  const SettingsRecoveryNotice({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final recovered = ref
        .watch(settingsServiceProvider)
        .recoveredCorruptSettings;
    final message = settings.hasError
        ? '设置加载失败，已停止保存以保护原数据。请检查本地存储后重启。'
        : recovered
        ? '设置数据损坏：原文已备份到本地 corrupt_settings_backup。有效偏好已保留，损坏字段暂用默认值。'
        : null;
    if (message == null) return child;
    return Column(
      children: [
        Material(
          color: Theme.of(context).colorScheme.errorContainer,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(message),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
