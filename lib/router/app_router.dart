import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:janus/router/route_constants.dart';
import 'package:janus/pages/AppShell/app_shell.dart';
import 'package:janus/pages/Inbox/inbox_page.dart';
import 'package:janus/pages/TaskPage/task_page.dart';
import 'package:janus/pages/SettingPage/setting_page.dart';
import 'package:janus/pages/FocusPage/focus_page.dart';
import 'package:janus/pages/InsightPage/insight_page.dart';

// subsetting pages
import 'package:janus/pages/SettingPage/subSettingPage/generalSetting/general_setting_page.dart';

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
    ),
    GoRoute(
      path: RoutePath.generalSetting,
      name: 'generalSetting',
      builder: (context, state) => const GeneralSettingPage(),
    ),
  ],
);
