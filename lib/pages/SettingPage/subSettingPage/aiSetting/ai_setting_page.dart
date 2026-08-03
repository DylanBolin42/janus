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
  bool _isHttpsError = false;

  @override
  void initState() {
    super.initState();
    final settings =
        ref.read(appSettingsNotifierProvider).valueOrNull ??
        const AppSettings();
    _endpointController = TextEditingController(text: settings.endPoint);
    _modelController = TextEditingController(text: settings.modelName);
    _apiKeyController = TextEditingController();

    _endpointController.addListener(_onEndpointChanged);
    _modelController.addListener(_onModelChanged);
    _apiKeyController.addListener(_onApiKeyChanged);

    // Load the obfuscated API key asynchronously from the settings service.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final service = ref.read(settingsServiceProvider);
      final apiKey = await service.loadApiKey();
      if (mounted) {
        _apiKeyController.removeListener(_onApiKeyChanged);
        _apiKeyController.text = apiKey;
        _apiKeyController.addListener(_onApiKeyChanged);
      }
    });
  }

  @override
  void dispose() {
    _endpointController.removeListener(_onEndpointChanged);
    _modelController.removeListener(_onModelChanged);
    _apiKeyController.removeListener(_onApiKeyChanged);
    _endpointController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _onEndpointChanged() {
    final val = _endpointController.text.trim();
    if (val.isEmpty) {
      if (_isHttpsError) {
        setState(() {
          _isHttpsError = false;
        });
      }
      ref.read(appSettingsNotifierProvider.notifier).setEndPoint('');
    } else {
      final uri = Uri.tryParse(val);
      if (uri != null && uri.scheme == 'https') {
        if (_isHttpsError) {
          setState(() {
            _isHttpsError = false;
          });
        }
        ref.read(appSettingsNotifierProvider.notifier).setEndPoint(val);
      } else {
        if (!_isHttpsError) {
          setState(() {
            _isHttpsError = true;
          });
        }
      }
    }
  }

  void _onModelChanged() {
    final val = _modelController.text;
    ref.read(appSettingsNotifierProvider.notifier).setModelName(val);
  }

  void _onApiKeyChanged() {
    final val = _apiKeyController.text;
    ref.read(settingsServiceProvider).saveApiKey(val);
  }

  @override
  Widget build(BuildContext context) {
    final settings =
        ref.watch(appSettingsNotifierProvider).valueOrNull ??
        const AppSettings();
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
                  title: Text('说明'),
                  leading: Icon(Icons.rocket_launch_rounded),
                  description: Text(
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
                      Row(
                        children: [
                          Text(
                            'Endpoint',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.base),
                      GlassTextField(
                        controller: _endpointController,
                        shape: LiquidRoundedSuperellipse(borderRadius: 64),
                      ),
                      if (_isHttpsError) ...[
                        const SizedBox(height: 4),
                        const Text(
                          '必须使用 HTTPS 地址 (防止中间人攻击)',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SettingsTile(
                  title: Text('API Key'),
                  trailing: SizedBox(
                    width: 160,
                    child: GlassTextField(
                      controller: _apiKeyController,
                      obscureText: true,
                      shape: LiquidRoundedSuperellipse(borderRadius: 64),
                    ),
                  ),
                ),
                SettingsTile(
                  title: Text('Model'),
                  trailing: SizedBox(
                    width: 160,
                    child: GlassTextField(
                      controller: _modelController,
                      shape: LiquidRoundedSuperellipse(borderRadius: 64),
                    ),
                  ),
                  description: Text('以官方提供的名称为准'),
                ),
              ],
            ),

            SettingsSection(
              title: Text('AI功能', style: tt.titleMedium),
              tiles: [
                SettingsTile(
                  title: Text('每日日报总结'),
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
                  title: Text('更完善的分析报告'),
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
                  title: Text('智慧文本日程提取'),
                  description: Text('指拥有更强的上下文理解能力和联想推理能力'),
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
                  title: Text('图片日程提取'),
                  description: Text('需要对应模型支持图片输入和图像理解'),
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
