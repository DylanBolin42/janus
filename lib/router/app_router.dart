import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:janus/pages/AppShell/AppShell.dart';
import 'package:janus/pages/Inbox/InboxPage.dart';
import 'package:janus/pages/TaskPage/task_page.dart';
import 'package:janus/pages/SettingPage/settingPage.dart';
import 'package:janus/pages/FocusPage/focusPage.dart';
import 'package:janus/pages/InsightPage/insight_page.dart';

// subsetting pages
import 'package:janus/pages/SettingPage/subSettingPage/generalSetting/general_setting_page.dart';
import 'package:janus/pages/SettingPage/subSettingPage/notificationSetting/notification_setting_page.dart';
import 'package:janus/pages/SettingPage/subSettingPage/focusSetting/focus_setting_page.dart';
import 'package:janus/pages/SettingPage/subSettingPage/storageSetting/storage_setting_page.dart';
import 'package:janus/pages/SettingPage/subSettingPage/syncSetting/sync_setting_page.dart';
import 'package:janus/pages/SettingPage/subSettingPage/aboutPage/about_page.dart';
import 'package:janus/pages/SettingPage/subSettingPage/planningSetting/planning_setting_page.dart';

/// Centralized route path constants.
///
/// Add a new static const for each new route.
class RoutePath {
  RoutePath._();
  // 一级目录
  static const String inbox = '/inbox';
  static const String task = '/task';
  static const String setting = '/setting'; // full-screen, no shell
  static const String focus = '/focus';
  static const String insights = '/insights';

  // 二级目录 (relative — nested under /setting)
  static const String generalSetting = 'general';
  static const String notificationSetting = 'notification';
  static const String focusSetting = 'focus';
  static const String storageSetting = 'storage';
  static const String syncSetting = 'sync';
  static const String aboutPage = 'about';
  static const String planningPage = 'planning';
}

/// Display names for each route, used in AppBars.
///
/// Keyed by [GoRoute.name]. Add a new entry for each new top-level route.
class RouteDisplayName {
  RouteDisplayName._();
  static const Map<String, String> names = {
    'inbox': 'Inbox',
    'task': '任务',
    'setting': '设置',
    'focus': '专注',
    'insights': '洞察',
  };
}

/// The single [GoRouter] instance for the application.
final GoRouter appRouter = GoRouter(
  initialLocation: RoutePath.inbox,
  routes: [
    /// 除设置页外所有页面的路由都在AppShell中，设置页为独立页面
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) =>
          AppShell(child: child),
      routes: [
        GoRoute(
          path: RoutePath.inbox,
          name: 'inbox',
          builder: (context, state) => const InboxPage(),
        ),
        GoRoute(
          path: RoutePath.task,
          name: 'task',
          builder: (context, state) => const TaskPage(),
        ),
        GoRoute(
          path: RoutePath.focus,
          name: 'focus',
          builder: (context, state) => const Focuspage(),
        ),
        GoRoute(
          path: RoutePath.insights,
          name: 'insights',
          builder: (context, state) => const InsightPage(),
        ),

        // --- Add new ShellRoute child pages here ---
      ],
    ),

    // Setting pages (not inside AppShell – covers the full screen)
    GoRoute(
      path: RoutePath.setting,
      name: 'setting',
      builder: (context, state) => const Settingpage(),
      routes: [
        GoRoute(
          path: RoutePath.generalSetting,
          name: 'generalSetting',
          builder: (context, state) => const GeneralSettingPage(),
        ),
        GoRoute(
          path: RoutePath.notificationSetting,
          name: 'notificationSetting',
          builder: (context, state) => const NotificationSettingPage(),
        ),
        GoRoute(
          path: RoutePath.focusSetting,
          name: 'focusSetting',
          builder: (context, state) => const FocusSettingPage(),
        ),
        GoRoute(
          path: RoutePath.storageSetting,
          name: 'storageSetting',
          builder: (context, state) => const StorageSettingPage(),
        ),
        GoRoute(
          path: RoutePath.syncSetting,
          name: 'syncSetting',
          builder: (context, state) => const SyncSettingPage(),
        ),
        GoRoute(
          path: RoutePath.aboutPage,
          name: 'aboutPage',
          builder: (context, state) => const AboutPage(),
        ),
        GoRoute(
          path: RoutePath.planningPage,
          name: 'planningSetting',
          builder: (context, state) => const PlanningSettingPage(),
        ),
      ],
    ),
  ],
);
