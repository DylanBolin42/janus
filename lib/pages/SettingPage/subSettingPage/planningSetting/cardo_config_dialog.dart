import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../services/cardo/cardo_config.dart';

/// Current policy and last load result are separate, so a rejected file never
/// appears to be the active source. This is also a manual reload entry point.
class CardoConfigDialog extends StatefulWidget {
  final CardoConfigService service;
  const CardoConfigDialog({super.key, required this.service});
  @override
  State<CardoConfigDialog> createState() => _CardoConfigDialogState();
}

class _CardoConfigDialogState extends State<CardoConfigDialog> {
  bool busy = false;
  Timer? refreshTimer;
  @override
  void initState() {
    super.initState();
    refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> reload() async {
    setState(() => busy = true);
    await widget.service.watchFile(CardoConfigService.configName);
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.service, c = s.current;
    return AlertDialog(
      title: const Text('优先级算法 · 当前配置'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '算法：${c.scoringVersion} · 格式：${c.version} · 修订：${c.revision}',
              ),
              Text('生效来源：${c.source}\n加载时间：${c.loadedAt.toIso8601String()}'),
              Text('有效权重：${s.diagnostics.effectiveWeights}'),
              const SizedBox(height: 16),
              const Text('应用私有目录中的 cardo-config.json；文件缺失恢复默认，格式错误保留当前配置'),
              const SizedBox(height: 16),
              Text(
                '最近尝试：${s.lastAttemptAt?.toIso8601String() ?? "无"}\n${s.attemptedSource ?? ""}\n${s.lastStatus}\n${s.lastError ?? ""}',
              ),
              Text('警告：${c.warnings.join("\n")}'),
              const SizedBox(height: 16),
              SelectableText(
                const JsonEncoder.withIndent('  ').convert(c.parameters),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : reload,
          child: const Text('重新加载配置'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}
