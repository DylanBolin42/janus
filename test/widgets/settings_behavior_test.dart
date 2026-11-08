import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:janus/pages/AppShell/app_shell.dart';
import 'package:janus/pages/SettingPage/subSettingPage/syncSetting/sync_setting_page.dart';
import 'package:drift/native.dart';
import 'package:janus/database/app_database.dart';
import 'package:janus/models/task.dart';
import 'package:janus/providers/database_provider.dart';
import 'package:janus/pages/SettingPage/subSettingPage/storageSetting/storage_setting_page.dart';
import 'package:janus/pages/SettingPage/subSettingPage/aboutPage/about_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/models/app_settings.dart';
import 'package:janus/pages/SettingPage/subSettingPage/focusSetting/focus_setting_page.dart';
import 'package:janus/pages/SettingPage/subSettingPage/notificationSetting/notification_setting_page.dart';
import 'package:janus/providers/settings_provider.dart';
import 'package:janus/services/settings_service.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('briefing time controls show persisted times and save edits', (
    tester,
  ) async {
    await SettingsService().save(
      const AppSettings(morningBriefingTime: TimeOfDay(hour: 7, minute: 15)),
    );
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(appSettingsProvider.future);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: NotificationSettingPage()),
      ),
    );
    await tester.pumpAndSettle();
    final pickers = tester
        .widgetList<CupertinoTimePickerButton>(
          find.byType(CupertinoTimePickerButton),
        )
        .toList();
    expect(pickers.first.initialTime, const TimeOfDay(hour: 7, minute: 15));
    pickers.first.onCompleted!(const TimeOfDay(hour: 6, minute: 45));
    await tester.pumpAndSettle();
    expect(
      (await SettingsService().load()).morningBriefingTime,
      const TimeOfDay(hour: 6, minute: 45),
    );
    expect(
      tester
          .widgetList<CupertinoTimePickerButton>(
            find.byType(CupertinoTimePickerButton),
          )
          .first
          .initialTime,
      const TimeOfDay(hour: 6, minute: 45),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('focus mode shows saved mode and updates selection after save', (
    tester,
  ) async {
    await SettingsService().save(
      const AppSettings(focusTimerMode: FocusTimerMode.stopwatch),
    );
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(appSettingsProvider.future);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: FocusSettingPage()),
      ),
    );
    await tester.pumpAndSettle();
    final selector = tester.widget<GlassSegmentedControl>(
      find.byType(GlassSegmentedControl),
    );
    expect(selector.selectedIndex, 1);
    selector.onSegmentSelected(2);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<GlassSegmentedControl>(find.byType(GlassSegmentedControl))
          .selectedIndex,
      2,
    );
    expect(
      (await SettingsService().load()).focusTimerMode,
      FocusTimerMode.pomodoro,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'storage deletion requires confirmation and refreshes real counts',
    (tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      await database.taskDao.createTask(
        TaskDraft(
          status: 0,
          title: 'keep until confirmed',
          ddl: DateTime(2026),
        ),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(database)],
          child: const MaterialApp(home: StorageSettingPage()),
        ),
      );
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();
      expect(find.text('任务：1，标签：0'), findsOneWidget);
      await tester.tap(find.text('删除数据库'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      expect(await database.taskDao.getAllTasks(), hasLength(1));
      await tester.tap(find.text('删除数据库'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('删除'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();
      expect(await database.taskDao.getAllTasks(), isEmpty);
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();
      expect(find.text('任务：0，标签：0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'about provides version information and copies actual repository URL',
    (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AboutPage())),
      );
      await tester.pumpAndSettle();
      expect(find.text('当前版本'), findsOneWidget);
      await tester.tap(find.text('Github主页'));
      await tester.pumpAndSettle();
      expect(copied, 'https://github.com/DylanBolin42/janus');
      expect(find.text('链接已复制，请在浏览器打开'), findsOneWidget);
    },
  );
  testWidgets('tab naming edits immediately update navigation and title', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(appSettingsProvider.future);
    final router = GoRouter(
      initialLocation: '/inbox',
      routes: [
        GoRoute(
          path: '/inbox',
          name: 'inbox',
          builder: (_, _) => const AppShell(child: SizedBox()),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('收件箱'), findsWidgets);
    await container
        .read(appSettingsProvider.notifier)
        .setTabNamingStyle(TabNamingStyle.professional);
    await tester.pumpAndSettle();
    expect(find.text('待处理'), findsWidgets);
    expect(find.text('任务管理'), findsWidgets);
    expect(find.text('收件箱'), findsNothing);
  });

  testWidgets('unavailable sync never displays enabled or claims success', (
    tester,
  ) async {
    await SettingsService().save(const AppSettings(syncEnabled: true));
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SyncSettingPage())),
    );
    await tester.pumpAndSettle();
    final toggle = tester
        .widgetList<GlassSwitch>(find.byType(GlassSwitch))
        .first;
    expect(toggle.value, isFalse);
    toggle.onChanged(true);
    await tester.pumpAndSettle();
    expect(find.text('同步及安全服务尚未接入，无法执行此操作'), findsOneWidget);
    expect(find.text('同步服务尚未接入，暂无流量统计'), findsOneWidget);
  });
}
