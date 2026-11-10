import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/database/app_database.dart';
import 'package:janus/services/cardo/cardo_config.dart';
import 'package:janus/services/cardo/cardo_data_service.dart';
import 'package:janus/services/cardo/cardo_scoring_service.dart';

/// Repeatable SQLite/in-process benchmark, not a device latency guarantee.
void main() {
  for (final count in [1000, 5000]) {
    test('Cardo benchmark: $count tasks, ${count * 10} events', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final config = CardoConfigService();
      addTearDown(db.close);
      addTearDown(config.dispose);
      final now = DateTime.utc(2026, 11, 8);
      config.replaceJson(
        '{"version":2,"factors":{"dependency":{"enabled":true,"weight":1},"success":{"enabled":true,"weight":1},"efficiency":{"enabled":true,"weight":1},"feedback":{"enabled":true,"weight":1}}}',
      );
      final service = CardoDataService(db, CardoScoringService(config));
      await db.transaction(() async {
        await db.batch((b) {
          for (var i = 1; i <= count; i++) {
            b.customStatement(
              'INSERT INTO tasks(id,title,ddl,priority,status,est_hour,est_minute,dependency_graph_known) VALUES (?, ?, ?, 3, 0, 1, 0, 1)',
              [i, 'task-$i', now.millisecondsSinceEpoch ~/ 1000],
            );
          }
          for (var i = 1; i <= count; i++) {
            if (i % 5 != 0) {
              b.customStatement(
                'INSERT INTO task_dependencies(predecessor,successor) VALUES (?, ?)',
                [i, i + 1],
              );
            }
            for (var j = 0; j < 10; j++) {
              b.customStatement(
                'INSERT INTO task_events(task_id,kind,occurred_at,minutes,estimated_minutes) VALUES (?, ?, ?, 30, 60)',
                [
                  i,
                  ['completed', 'failed', 'accepted', 'ignored'][j % 4],
                  now.millisecondsSinceEpoch ~/ 1000,
                ],
              );
            }
          }
        });
      });
      await service.calculate(now: now); // Warm SQL/JIT caches; not timed.
      final full = <int>[], page = <int>[];
      for (var i = 0; i < 5; i++) {
        final watch = Stopwatch()..start();
        final results = await service.calculate(now: now);
        full.add(watch.elapsedMicroseconds);
        expect(results, hasLength(count));
        watch.reset();
        final selected = await service.calculate(
          now: now,
          afterId: count ~/ 2,
          limit: 100,
        );
        page.add(watch.elapsedMicroseconds);
        expect(selected, hasLength(100));
        expect(selected.every((r) => r.taskId > count ~/ 2), isTrue);
      }
      full.sort();
      page.sort();
      // Deliberately report observations without a flaky wall-clock assertion.
      // ignore: avoid_print
      print(
        'CARDO_BENCH tasks=$count events=${count * 10} edges=${count * 4 ~/ 5} samples=5 full_us=$full page100_us=$page median_full_us=${full[2]} median_page_us=${page[2]}',
      );
    });
  }
}
