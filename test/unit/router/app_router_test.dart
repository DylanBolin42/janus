import 'package:flutter_test/flutter_test.dart';
import 'package:janus/router/app_router.dart';

void main() {
  group('RoutePath', () {
    test('inbox route path', () {
      expect(RoutePath.inbox, '/inbox');
    });

    test('task route path', () {
      expect(RoutePath.task, '/task');
    });

    test('focus route path', () {
      expect(RoutePath.focus, '/focus');
    });

    test('insights route path', () {
      expect(RoutePath.insights, '/insights');
    });

    test('setting route path', () {
      expect(RoutePath.setting, '/setting');
    });
  });

  group('RouteDisplayName', () {
    test('contains all expected route names', () {
      expect(RouteDisplayName.names.keys,
          containsAll(['inbox', 'task', 'focus', 'insights', 'setting']));
    });

    test('inbox display name', () {
      expect(RouteDisplayName.names['inbox'], 'Inbox');
    });

    test('task display name', () {
      expect(RouteDisplayName.names['task'], '任务');
    });

    test('focus display name', () {
      expect(RouteDisplayName.names['focus'], '专注');
    });

    test('insights display name', () {
      expect(RouteDisplayName.names['insights'], '洞察');
    });

    test('setting display name', () {
      expect(RouteDisplayName.names['setting'], '设置');
    });

    test('all display name values are non-empty', () {
      for (final name in RouteDisplayName.names.values) {
        expect(name, isNotEmpty);
      }
    });
  });

  group('appRouter', () {
    test('router is not null', () {
      expect(appRouter, isNotNull);
    });

    test('router has routes configured', () {
      expect(appRouter.configuration.routes, isNotEmpty);
    });
  });
}
