import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/models/app_settings.dart';
import 'package:janus/providers/settings_provider.dart';
import 'package:janus/shared/custom_app_settings_tile.dart';
import 'package:janus/shared/custom_appbar.dart';
import 'package:janus/theme/theme.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class AiSettingPage extends ConsumerStatefulWidget {
  const AiSettingPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AiSettingPageState();
}

class _AiSettingPageState extends ConsumerState<AiSettingPage> {
  late final TextEditingController _endpointController;
  late final TextEditingController _apiKeyController;
  late final TextEditingController _modelController;

  bool _isInitialized = false;
  String? _endpointError;

  @override
  void initState() {
    super.initState();
    _endpointController = TextEditingController();
    _apiKeyController = TextEditingController();
    _modelController = TextEditingController();
  }

  @override
  void dispose() {
    _endpointController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _validateAndSaveEndpoint(String val) {
    final trimmed = val.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _endpointError = null;
      });
      ref.read(appSettingsNotifierProvider.notifier).setEndPoint('');
      return;
    }

    final uri = Uri.tryParse(trimmed);
    final isLocal =
        trimmed.contains('localhost') || trimmed.contains('127.0.0.1');

    if (uri == null || (uri.scheme != 'https' && !isLocal)) {
      setState(() {
        _endpointError = '为了安全，远程端点必须使用 HTTPS 协议以防止 API Key 被拦截';
      });
      return;
    }

    setState(() {
      _endpointError = null;
    });
    ref.read(appSettingsNotifierProvider.notifier).setEndPoint(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsNotifierProvider);
    final apiKeyAsync = ref.watch(aiApiKeyProvider);

    final settings = settingsAsync.valueOrNull ?? const AppSettings();
    final apiKey = apiKeyAsync.valueOrNull ?? '';

    if (settingsAsync is AsyncData && apiKeyAsync is AsyncData) {
      if (!_isInitialized) {
        _endpointController.text = settings.endPoint;
        _modelController.text = settings.modelName;
        _apiKeyController.text = apiKey;
        _isInitialized = true;
      }
    }

    final tt = Theme.of(context).textTheme;

    return GlassScaffold(
      topEdgeFade: false,
      appBar: const CustomAppbar(title: 'AI', showBack: true),
      body: CustomAppbar.wrapBody(
        context,
        SettingsList(
          sections: [
            SettingsSection(
              tiles: [
                SettingsTile(
                  title: const Text('说明'),
                  leading: const Icon(Icons.rocket_launch_rounded),
                  description: const Text(
                    'AI设置内的设置项如启用能够增进用户体验，但不开启也不会影响基础使用。\n推荐用户理性选择调用的模型，本应用程序不需要大容量上下文推理 and 非常严谨的逻辑推导，因此推荐价格便宜的模型如Deepseek Flash，而不是Fable等高端模型。',
                  ),
                ),
              ],
            ),
            SettingsSection(
              title: Text('配置', style: tt.titleMedium),
              tiles: [
                CustomAppSettingsTile(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text(
                            'Endpoint',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.base),
                      GlassTextField(
                        controller: _endpointController,
                        shape: LiquidRoundedSuperellipse(borderRadius: 64),
                        onChanged: _validateAndSaveEndpoint,
                      ),
                      if (_endpointError != null) ...[
                        const SizedBox(height: AppSpacing.base / 2),
                        Text(
                          _endpointError!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SettingsTile(
                  title: const Text('API Key'),
                  trailing: SizedBox(
                    width: 160,
                    child: GlassTextField(
                      controller: _apiKeyController,
                      obscureText: true,
                      shape: LiquidRoundedSuperellipse(borderRadius: 64),
                      onChanged: (val) {
                        ref
                            .read(appSettingsNotifierProvider.notifier)
                            .setAiApiKey(val.trim());
                      },
                    ),
                  ),
                ),
                SettingsTile(
                  title: const Text('Model'),
                  trailing: SizedBox(
                    width: 160,
                    child: GlassTextField(
                      controller: _modelController,
                      shape: LiquidRoundedSuperellipse(borderRadius: 64),
                      onChanged: (val) {
                        ref
                            .read(appSettingsNotifierProvider.notifier)
                            .setModelName(val.trim());
                      },
                    ),
                  ),
                  description: const Text('以官方提供的名称为准'),
                ),
              ],
            ),

            SettingsSection(
              title: Text('AI功能', style: tt.titleMedium),
              tiles: [
                SettingsTile(
                  title: const Text('每日日报总结'),
                  trailing: GlassSwitch(
                    value: settings.aiDailySummary,
                    onChanged: (val) {
                      ref
                          .read(appSettingsNotifierProvider.notifier)
                          .setUseAiDailySummary(val);
                    },
                  ),
                ),
                SettingsTile(
                  title: const Text('更完善的分析报告'),
                  trailing: GlassSwitch(
                    value: settings.aiAnalyseReport,
                    onChanged: (val) {
                      ref
                          .read(appSettingsNotifierProvider.notifier)
                          .setAiAnalyseReport(val);
                    },
                  ),
                ),
                SettingsTile(
                  title: const Text('智慧文本日程提取'),
                  description: const Text('指拥有更强的上下文理解能力 and 联想推理能力'),
                  trailing: GlassSwitch(
                    value: settings.aiTextToTask,
                    onChanged: (val) {
                      ref
                          .read(appSettingsNotifierProvider.notifier)
                          .setAiTextToTask(val);
                    },
                  ),
                ),
                SettingsTile(
                  title: const Text('图片日程提取'),
                  description: const Text('需要对应模型支持图片输入和图像理解'),
                  trailing: GlassSwitch(
                    value: settings.aiPicToTask,
                    onChanged: (val) {
                      ref
                          .read(appSettingsNotifierProvider.notifier)
                          .setAiPicToTask(val);
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
