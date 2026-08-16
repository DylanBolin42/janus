import 'package:flutter_test/flutter_test.dart';
import 'package:janus/router/route_constants.dart';

void main() {
  group('RoutePath', () {
    test('top-level route paths are defined', () {
      expect(RoutePath.inbox, '/inbox');
      expect(RoutePath.task, '/task');
      expect(RoutePath.setting, '/setting');
      expect(RoutePath.focus, '/focus');
      expect(RoutePath.insights, '/insights');
    });

    test('nested route path is defined', () {
      expect(RoutePath.generalSetting, '/setting/general');
    });
  });

  group('RouteDisplayName', () {
    test('names map contains every top-level route', () {
      expect(RouteDisplayName.names, hasLength(5));
      expect(RouteDisplayName.names['inbox'], 'Inbox');
      expect(RouteDisplayName.names['task'], '任务');
      expect(RouteDisplayName.names['setting'], '设置');
      expect(RouteDisplayName.names['focus'], '专注');
      expect(RouteDisplayName.names['insights'], '洞察');
    });
  });
}
