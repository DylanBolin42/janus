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
  final _endpointController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _modelController = TextEditingController();
  bool _isInitialized = false;

  @override
  void dispose() {
    _endpointController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsNotifierProvider);
    final apiKeyAsync = ref.watch(apiKeyProvider);

    final settings = settingsAsync.valueOrNull ?? const AppSettings();
    final apiKey = apiKeyAsync.valueOrNull ?? '';

    if (!_isInitialized && settingsAsync.hasValue && apiKeyAsync.hasValue) {
      _endpointController.text = settings.endPoint;
      _modelController.text = settings.modelName;
      _apiKeyController.text = apiKey;
      _isInitialized = true;
    }

    final endpointText = _endpointController.text;
    final isEndpointValid =
        endpointText.isEmpty ||
        endpointText.toLowerCase().startsWith('https://');

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
                    'AI设置内的设置项如启用能够增进用户体验，但不开启也不会影响基础使用。\n推荐用户理性选择调用的模型，本应用程序不需要大容量上下文推理和非常严谨的逻辑推导，因此推荐价格便宜的模型如Deepseek Flash，而不是Fable等高端模型。',
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
                        onChanged: (val) {
                          setState(() {}); // Dynamically update isEndpointValid
                          if (val.isEmpty ||
                              val.toLowerCase().startsWith('https://')) {
                            ref
                                .read(appSettingsNotifierProvider.notifier)
                                .setEndPoint(val);
                          }
                        },
                        shape: LiquidRoundedSuperellipse(borderRadius: 64),
                      ),
                      if (!isEndpointValid) ...[
                        const SizedBox(height: 4),
                        const Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.redAccent,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '安全提示: Endpoint 必须使用 HTTPS 协议以防止中间人攻击(MITM)',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
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
                      onChanged: (val) {
                        ref.read(apiKeyProvider.notifier).setApiKey(val);
                      },
                      obscureText: true,
                      shape: LiquidRoundedSuperellipse(borderRadius: 64),
                    ),
                  ),
                ),
                SettingsTile(
                  title: const Text('Model'),
                  trailing: SizedBox(
                    width: 160,
                    child: GlassTextField(
                      controller: _modelController,
                      onChanged: (val) {
                        ref
                            .read(appSettingsNotifierProvider.notifier)
                            .setModelName(val);
                      },
                      shape: LiquidRoundedSuperellipse(borderRadius: 64),
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
