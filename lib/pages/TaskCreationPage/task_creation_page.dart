import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/models/app_settings.dart';
// sub Page
import 'package:janus/pages/TaskCreationPage/subPage/classic_page.dart';
import 'package:janus/providers/settings_provider.dart';
import 'package:janus/theme/theme.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class TaskCreationPage {
  const TaskCreationPage._();

  static List<SliverWoltModalSheetPage> createTaskPage(BuildContext context) {
    return [
      WoltModalSheetPage(
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
        trailingNavBarWidget: Padding(
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
              onPressed: () {},
            ),
          ),
        ),
        pageTitle: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('新建任务', style: Theme.of(context).textTheme.titleMedium),
        ),
        child: Consumer(
          builder: (context, ref, _) {
            final settings =
                ref.watch(appSettingsNotifierProvider).valueOrNull ??
                const AppSettings();
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.base),
                  switch (settings.taskCreationMode) {
                    TaskCreationMode.classic => const ClassicPage(),
                    TaskCreationMode.fillInBlanks => const Column(),
                    TaskCreationMode.naturalLanguage => const Column(),
                  },
                ],
              ),
            );
          },
        ),
      ),
    ];
  }
}
