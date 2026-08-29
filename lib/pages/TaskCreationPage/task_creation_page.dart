import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/models/app_settings.dart';
// sub Page
import 'package:janus/pages/TaskCreationPage/subPage/classic_page.dart';
import 'package:janus/providers/database_provider.dart';
import 'package:janus/providers/settings_provider.dart';
import 'package:janus/providers/task_draft_provider.dart';
import 'package:janus/services/logger_service.dart';
import 'package:janus/theme/theme.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class TaskCreationPage {
  const TaskCreationPage._();

  static List<SliverWoltModalSheetPage> createTaskPage(BuildContext context) {
    return [
      WoltModalSheetPage(
        useSafeArea: false,
        leadingNavBarWidget: Padding(
          padding: const EdgeInsets.all(8.0),
          child: M3ETheme(
            data: M3ETheme.of(context).withColorScheme(
              M3ETheme.of(context).colorScheme.copyWith(
                primary: Theme.of(context).colorScheme.surfaceContainer,
                onPrimary: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            child: M3EIconButton(
              icon: Icon(Icons.close_rounded),
              variant: M3EIconButtonVariant.filled,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        trailingNavBarWidget: Consumer(
          builder: (context, ref, _) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: M3ETheme(
                data: M3ETheme.of(context).withColorScheme(
                  M3ETheme.of(context).colorScheme.copyWith(
                    primary: Theme.of(context).colorScheme.primaryContainer,
                    onPrimary: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                child: M3EIconButton(
                  icon: Icon(
                    Icons.add_rounded,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  variant: M3EIconButtonVariant.filled,
                  onPressed: () => _handleCreate(context, ref),
                ),
              ),
            );
          },
        ),
        hasTopBarLayer: true,
        isTopBarLayerAlwaysVisible: true,
        topBarTitle: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('新建任务', style: Theme.of(context).textTheme.titleMedium),
        ),
        child: Consumer(
          builder: (context, ref, _) {
            final settings =
                ref.watch(appSettingsProvider).value ?? const AppSettings();
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.marginMobile,
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.base),
                  switch (settings.taskCreationMode) {
                    TaskCreationMode.classic => const ClassicPage(),
                    TaskCreationMode.fillInBlanks => const Column(),
                    TaskCreationMode.naturalLanguage => const Column(),
                  },
                  const SizedBox(height: AppSpacing.base * 2),
                ],
              ),
            );
          },
        ),
      ),
    ];
  }

  /// 新建任务提交：校验 → 落库 → 重置草稿 → 关闭弹窗
  static Future<void> _handleCreate(BuildContext context, WidgetRef ref) async {
    final draft = ref.read(taskDraftProvider);
    final title = draft.title.trim();
    if (title.isEmpty || draft.ddl == null) {
      if (!context.mounted) return;
      GlassToast.show(
        position: GlassToastPosition.top,
        context,
        message: '请填写任务标题和截止时间',
        type: GlassToastType.error,
      );
      return;
    }

    final dao = ref.read(taskDaoProvider);
    try {
      await dao.createTask(draft.copyWith(title: title, status: 0));
      AppLogger.i('创建任务成功：${draft.title}');
      ref.read(taskDraftProvider.notifier).reset();
      if (!context.mounted) return;
      Navigator.of(context).pop();
    } catch (e, stackTrace) {
      AppLogger.e('创建任务失败', error: e, stackTrace: stackTrace);
      if (!context.mounted) return;
      GlassToast.show(
        position: GlassToastPosition.top,
        context,
        message: '创建任务失败，请重试',
        type: GlassToastType.error,
      );
    }
  }
}
