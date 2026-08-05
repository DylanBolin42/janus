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
  String? _endpointError;

  @override
  void initState() {
    super.initState();
    final settings =
        ref.read(appSettingsNotifierProvider).valueOrNull ??
        const AppSettings();
    _endpointController = TextEditingController(text: settings.endPoint);
    _modelController = TextEditingController(text: settings.modelName);
    _apiKeyController = TextEditingController();

    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final service = ref.read(settingsServiceProvider);
    final key = await service.getApiKey();
    if (mounted) {
      setState(() {
        _apiKeyController.text = key;
      });
    }
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

    Uri? uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme) {
      uri = Uri.tryParse('https://$trimmed');
    }

    if (uri == null || uri.host.isEmpty) {
      setState(() {
        _endpointError = '请输入有效的URL';
      });
      return;
    }

    if (uri.scheme != 'https') {
      final host = uri.host.toLowerCase();
      if (host != 'localhost' && host != '127.0.0.1' && host != '::1') {
        setState(() {
          _endpointError = '远程端点必须使用HTTPS协议';
        });
        return;
      }
    }

    setState(() {
      _endpointError = null;
    });
    ref.read(appSettingsNotifierProvider.notifier).setEndPoint(trimmed);
  }

  void _validateAndSaveApiKey(String val) {
    ref.read(appSettingsNotifierProvider.notifier).setApiKey(val);
  }

  void _validateAndSaveModelName(String val) {
    ref.read(appSettingsNotifierProvider.notifier).setModelName(val);
  }

  @override
  Widget build(BuildContext context) {
    final settings =
        ref.watch(appSettingsNotifierProvider).valueOrNull ??
        const AppSettings();
    final tt = Theme.of(context).textTheme;

    return GlassScaffold(
      topEdgeFade: false,
      appBar: CustomAppbar(title: 'AI', showBack: true),
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
                        onChanged: _validateAndSaveEndpoint,
                      ),
                      if (_endpointError != null) ...[
                        SizedBox(height: 4),
                        Text(
                          _endpointError!,
                          style: const TextStyle(
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
                      onChanged: _validateAndSaveApiKey,
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
                      onChanged: _validateAndSaveModelName,
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
