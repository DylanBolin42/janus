import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/models/app_settings.dart';
import 'package:janus/providers/settings_provider.dart';
import 'package:janus/shared/custom_app_settings_tile.dart';
import 'package:janus/shared/custom_appbar.dart';
import 'package:janus/theme/theme.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Validates whether an AI endpoint URL is safe to use.
///
/// Enforces HTTPS protocol for remote endpoints to prevent MitM attacks,
/// but allows HTTP for local development loopback hosts (localhost, 127.0.0.1, ::1).
bool isValidEndpointUrl(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return true;
  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return false;
  if (uri.scheme == 'https') return true;
  if (uri.scheme == 'http') {
    final host = uri.host.toLowerCase();
    return host == 'localhost' || host == '127.0.0.1' || host == '::1' || host == '[::1]';
  }
  return false;
}

class AiSettingPage extends ConsumerStatefulWidget {
  const AiSettingPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AiSettingPageState();
}

class _AiSettingPageState extends ConsumerState<AiSettingPage> {
  String? _endpointError;

  @override
  Widget build(BuildContext context) {
    final settings =
        ref.watch(appSettingsProvider).value ?? const AppSettings();
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
              //TODO: 接入TextField持久化逻辑
              title: Text('配置', style: tt.titleMedium),
              tiles: [
                CustomAppSettingsTile(
                  child: Column(
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
                        shape: LiquidRoundedSuperellipse(borderRadius: 64),
                        onChanged: (value) {
                          setState(() {
                            if (value.isNotEmpty && !isValidEndpointUrl(value)) {
                              _endpointError = '仅支持 HTTPS 协议或本地 HTTP 地址';
                            } else {
                              _endpointError = null;
                            }
                          });
                        },
                      ),
                      if (_endpointError != null) ...[
                        SizedBox(height: AppSpacing.base),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _endpointError!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                //SettingsTile(
                //  title: Text('Endpoint'),
                //  trailing: SizedBox(
                //    width: 160,
                //    child: GlassTextField(
                //      shape: LiquidRoundedSuperellipse(borderRadius: 64),
                //    ),
                //  ),
                //  description: Text('暂仅支持OpenAI格式请求'),
                //),
                SettingsTile(
                  title: Text('API Key'),

                  trailing: SizedBox(
                    width: 160,
                    child: GlassTextField(
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
                          .read(appSettingsProvider.notifier)
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
                          .read(appSettingsProvider.notifier)
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
                          .read(appSettingsProvider.notifier)
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
                          .read(appSettingsProvider.notifier)
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
