import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:janus/theme/theme.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class NotificationSettingPage extends ConsumerStatefulWidget {
  const NotificationSettingPage({super.key});

  @override
  ConsumerState<NotificationSettingPage> createState() =>
      _NotificationSettingPageState();
}

class _NotificationSettingPageState
    extends ConsumerState<NotificationSettingPage> {
  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text('通知'),
        leading: GlassIconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: AppSpacing.topSafeArea),
          SettingsSection(
            tiles: [
              SettingsTile.switchTile(
                title: Text('是否通知'),
                onToggle: (_) {},
                initialValue: false, //TODO: 更改逻辑
              ),
            ],
          ),
        ],
      ),
    );
  }
}
