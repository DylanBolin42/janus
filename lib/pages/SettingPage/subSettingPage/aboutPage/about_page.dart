import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/shared/custom_app_settings_tile.dart';
import 'package:janus/shared/custom_appbar.dart';
import 'package:janus/theme/theme.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:janus/shared/flex_setting_section.dart';

class AboutPage extends ConsumerStatefulWidget {
  const AboutPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AboutPageState();
}

class _AboutPageState extends ConsumerState<AboutPage> {
  void _copyLink(String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('链接已复制，请在浏览器打开')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassScaffold(
        edgeFade: false,
        appBar: CustomAppbar(title: '关于', showBack: true),
        body: CustomAppbar.wrapBody(
          context,
          SettingsList(
            sections: [
              SettingsSection(
                tiles: [
                  CustomAppSettingsTile(child: Text('Janus')),
                  SettingsTile(
                    title: const Text('当前版本'),
                    description: const Text(
                      '${String.fromEnvironment('FLUTTER_BUILD_NAME', defaultValue: '未知版本')}+'
                      '${String.fromEnvironment('FLUTTER_BUILD_NUMBER', defaultValue: '未知构建')}',
                    ),
                  ),
                  SettingsTile(
                    title: Text('版本检测'),
                    leading: Icon(Icons.update_rounded),
                    // TODO(JANUS-15): 缺少发行版本查询和平台更新服务。
                    description: Text('自动更新尚未接入'),
                    trailing: Icon(Icons.navigate_next_rounded),
                  ),
                ],
              ),
              SettingsSection(
                tiles: [
                  SettingsTile(
                    title: Text('Issue报告'),
                    onPressed: (_) => _copyLink(
                      'https://github.com/DylanBolin42/janus/issues/new',
                    ),
                    leading: Icon(Icons.bug_report_rounded),
                    trailing: Icon(Icons.navigate_next_rounded),
                  ),
                  SettingsTile(
                    title: Text('功能建议'),
                    onPressed: (_) => _copyLink(
                      'https://github.com/DylanBolin42/janus/issues/new',
                    ),
                    leading: Icon(Icons.mail_rounded),
                    trailing: Icon(Icons.navigate_next_rounded),
                  ),
                  SettingsTile(
                    title: Text('Github主页'),
                    onPressed: (_) =>
                        _copyLink('https://github.com/DylanBolin42/janus'),
                    leading: FaIcon(FontAwesomeIcons.github),
                    trailing: Icon(Icons.navigate_next_rounded),
                  ),
                  SettingsTile(
                    title: Text('开源许可证'),
                    onPressed: (_) => showLicensePage(
                      context: context,
                      applicationName: 'Janus',
                    ),
                    leading: Icon(MdiIcons.license),
                    trailing: Icon(Icons.navigate_next_rounded),
                  ),
                ],
              ),
              SettingsSection(
                tiles: [
                  SettingsTile(
                    title: Text('开源项目引用清单'),
                    onPressed: (_) => showLicensePage(
                      context: context,
                      applicationName: 'Janus',
                    ),
                    leading: Icon(MdiIcons.import),
                    trailing: Icon(Icons.navigate_next_rounded),
                  ),
                  SettingsTile(
                    // TODO(JANUS-15): 项目尚未提供 AIGC 声明内容和捐赠渠道。
                    title: Text('AIGC声明清单'),
                    description: Text('声明清单尚未提供'),
                    leading: Icon(MdiIcons.robot),
                    trailing: Icon(Icons.navigate_next_rounded),
                  ),
                ],
              ),
              FlexSettingSection(
                tiles: [
                  FlexRow(
                    children: [
                      FlexTile(
                        onTap: (_) =>
                            _copyLink('https://github.com/DylanBolin42/janus'),
                        child: Center(
                          child: Row(
                            children: [
                              Icon(Icons.star_rounded),
                              SizedBox(width: AppSpacing.base),
                              Text(
                                'Github star',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      FlexTile(
                        child: Center(
                          child: Row(
                            children: [
                              Icon(MdiIcons.coffeeToGo),
                              SizedBox(width: AppSpacing.base),
                              Text(
                                '捐赠',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
