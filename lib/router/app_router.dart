import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:janus/pages/AppShell/app_shell.dart';
import 'package:janus/pages/Inbox/inbox_page.dart';
import 'package:janus/pages/TaskPage/task_page.dart';
import 'package:janus/pages/SettingPage/setting_page.dart';
import 'package:janus/pages/FocusPage/focus_page.dart';
import 'package:janus/pages/InsightPage/insight_page.dart';

/// Centralized route path constants.
///
/// Add a new static const for each new route.
class RoutePath {
  RoutePath._();
  static const String inbox = '/inbox';
  static const String task = '/task';
  static const String setting = '/setting';
  static const String focus = '/focus';
  static const String insights = '/insights';
}

/// The single [GoRouter] instance for the application.
final GoRouter appRouter = GoRouter(
  initialLocation: RoutePath.inbox,
  routes: [
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) =>
          AppShell(child: child),
      routes: [
        GoRoute(
          path: RoutePath.inbox,
          name: 'atrium',
          builder: (context, state) => const AtriumPage(),
        ),
        GoRoute(
          path: RoutePath.task,
          name: 'task',
          builder: (context, state) => const TaskPage(),
        ),
        GoRoute(
          path: RoutePath.setting,
          name: 'setting',
          builder: (context, state) => const Settingpage(),
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
        // --- Add new pages here ---
      ],
    ),
  ],
);
