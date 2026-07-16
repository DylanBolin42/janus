import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
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
                  title: Text('版本检测'),
                  leading: Icon(Icons.update_rounded),
                  description: Text('检测最新版本并自动更新'),
                ),
              ],
            ),
            SettingsSection(
              tiles: [
                SettingsTile(
                  title: Text('Issue报告'),
                  leading: Icon(Icons.bug_report_rounded),
                ),
                SettingsTile(
                  title: Text('功能建议'),
                  leading: Icon(Icons.mail_rounded),
                ),
                SettingsTile(
                  title: Text('Github主页'),
                  leading: FaIcon(FontAwesomeIcons.github),
                ),
                SettingsTile(
                  title: Text('开源许可证'),
                  leading: Icon(MdiIcons.license),
                ),
              ],
            ),
            SettingsSection(
              tiles: [
                SettingsTile(
                  title: Text('开源项目引用清单'),
                  leading: Icon(MdiIcons.import),
                ),
                SettingsTile(
                  title: Text('AIGC声明清单'),
                  leading: Icon(MdiIcons.robot),
                ),
              ],
            ),
            FlexSettingSection(
              tiles: [
                FlexRow(
                  children: [
                    FlexTile(
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
    );
  }
}
