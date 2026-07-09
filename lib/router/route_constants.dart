/// Centralized route path constants and display names.
///
/// Extracted to avoid circular dependencies between [app_router] and page widgets.
library;

/// Route path constants.
///
/// Add a new static const for each new route.
class RoutePath {
  RoutePath._();
  // 一级目录
  static const String inbox = '/inbox';
  static const String task = '/task';
  static const String setting = '/setting';
  static const String focus = '/focus';
  static const String insights = '/insights';

  // 二级目录
  static const String generalSetting = '/setting/general';
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
