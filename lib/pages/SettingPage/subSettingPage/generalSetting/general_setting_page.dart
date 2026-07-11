import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/shared/custom_appbar.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:janus/models/app_settings.dart';
import 'package:janus/providers/settings_provider.dart';

/// 通用设置页 — 外观、语言、命名风格、权限
///
/// All state is managed via riverpod providers and persisted
/// to [shared_preferences] automatically.
class GeneralSettingPage extends ConsumerWidget {
  const GeneralSettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the async settings — use defaults while loading
    final settings =
        ref.watch(appSettingsNotifierProvider).valueOrNull ??
        const AppSettings();
    // define text style
    final tt = Theme.of(context).textTheme;

    return GlassScaffold(
      topEdgeFade: false,
      appBar: const CustomAppbar(title: '通用', showBack: true),
      body: CustomAppbar.wrapBody(
        context,
        SettingsList(
          maxWidth: 800,
          sections: [
            // ── 外观 ────────────────────────────────────────────────
            SettingsSection(
              title: Text('外观', style: tt.titleMedium),
              tiles: [
                SettingsTile.navigation(
                  title: const Text('主题色'),
                  leading: const Icon(Icons.color_lens_rounded),
                  description: const Text('选择属于你的主题色'),
                  onPressed: (_) {},
                ),

                // 显示模式 — 明暗/跟随系统
                SettingsTile(
                  leading: const Icon(Icons.light_mode_rounded),
                  title: const Text('显示模式'),
                  description: const Text('选择明暗模式或者根跟随系统'),
                  trailing: GlassPullDownButton(
                    icon: Icon(settings.themeMode.icon),
                    label: settings.themeMode.label,
                    buttonWidth: 120,
                    buttonShape: const LiquidRoundedRectangle(borderRadius: 64),
                    items: AppThemeMode.values.map((mode) {
                      final isSelected = settings.themeMode == mode;
                      return GlassMenuItem(
                        title: mode.label,
                        icon: Icon(
                          isSelected ? Icons.check_rounded : mode.icon,
                          size: 20,
                        ),
                        isSelected: isSelected,
                        onTap: () {
                          ref
                              .read(appSettingsNotifierProvider.notifier)
                              .setThemeMode(mode);
                        },
                      );
                    }).toList(),
                  ),
                ),

                // 液态玻璃渲染强度
                SettingsTile(
                  leading: const Icon(Icons.computer_rounded),
                  title: const Text('液态玻璃渲染强度'),
                  description: const Text('根据设备性能，请理性选择'),
                  trailing: GlassPullDownButton(
                    icon: Icon(settings.glassIntensity.icon),
                    label: settings.glassIntensity.label,
                    buttonWidth: 120,
                    buttonShape: const LiquidRoundedRectangle(borderRadius: 64),
                    items: GlassIntensity.values.map((intensity) {
                      final isSelected = settings.glassIntensity == intensity;
                      return GlassMenuItem(
                        title: intensity.label,
                        icon: Icon(
                          isSelected ? Icons.check_rounded : intensity.icon,
                          size: 20,
                        ),
                        isSelected: isSelected,
                        onTap: () {
                          ref
                              .read(appSettingsNotifierProvider.notifier)
                              .setGlassIntensity(intensity);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            // ── 语言 ────────────────────────────────────────────────
            SettingsSection(
              title: Text('语言', style: tt.titleMedium),
              tiles: [
                SettingsTile(
                  title: const Text('语言'),
                  leading: const Icon(Icons.language_rounded),
                  description: const Text('配置显示语言'),
                  trailing: GlassPullDownButton(
                    icon: Icon(settings.language.icon),
                    label: settings.language.label,
                    buttonWidth: 120,
                    buttonShape: const LiquidRoundedRectangle(borderRadius: 64),
                    items: AppLanguage.values.map((lang) {
                      final isSelected = settings.language == lang;
                      return GlassMenuItem(
                        title: lang.label,
                        icon: Icon(
                          isSelected ? Icons.check_rounded : lang.icon,
                          size: 20,
                        ),
                        isSelected: isSelected,
                        onTap: () {
                          ref
                              .read(appSettingsNotifierProvider.notifier)
                              .setLanguage(lang);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            // ── 命名风格 ────────────────────────────────────────────
            SettingsSection(
              title: Text('命名风格', style: tt.titleMedium),
              tiles: [
                SettingsTile(
                  title: const Text('Tab命名风格'),
                  leading: const Icon(Icons.tab_rounded),
                  trailing: GlassPullDownButton(
                    icon: Icon(settings.tabNamingStyle.icon),
                    label: settings.tabNamingStyle.label,
                    buttonWidth: 120,
                    buttonShape: const LiquidRoundedRectangle(borderRadius: 64),
                    items: TabNamingStyle.values.map((style) {
                      final isSelected = settings.tabNamingStyle == style;
                      return GlassMenuItem(
                        title: style.label,
                        icon: Icon(
                          isSelected ? Icons.check_rounded : style.icon,
                          size: 20,
                        ),
                        isSelected: isSelected,
                        onTap: () {
                          ref
                              .read(appSettingsNotifierProvider.notifier)
                              .setTabNamingStyle(style);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            // ── 权限 ────────────────────────────────────────────────
            SettingsSection(
              title: Text('权限', style: tt.titleMedium),
              tiles: [
                SettingsTile.navigation(
                  title: const Text('电池优化'),
                  description: const Text('该服务需要保持后台运行以实现定时提醒等'),
                  leading: const Icon(Icons.battery_full_rounded),
                  onPressed: (_) {},
                ),
                SettingsTile.navigation(
                  title: const Text('自启动'),
                  description: const Text('该服务需要保证每次重启设备后仍能够正常运行'),
                  leading: const Icon(Icons.start_rounded),
                  onPressed: (_) {},
                ),
                SettingsTile.navigation(
                  title: const Text('无障碍服务'),
                  description: const Text('该权限为敏感权限！！！用于在专注时屏蔽其他可能干扰专注进程的应用程序'),
                  leading: const Icon(Icons.accessibility_new_rounded),
                  onPressed: (_) {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
