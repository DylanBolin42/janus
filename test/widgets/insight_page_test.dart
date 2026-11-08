import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/database/app_database.dart';
import 'package:janus/models/insight_summary.dart';
import 'package:janus/pages/InsightPage/insight_page.dart';
import 'package:janus/providers/database_provider.dart';
import 'package:janus/theme/theme.dart';

void main() {
  testWidgets('database updates and period round trips retain real task data', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final start = InsightPeriod.week.start(DateTime.now());
    await db
        .into(db.tasks)
        .insert(
          TasksCompanion.insert(
            title: '真实任务',
            ddl: start,
            status: const Value(1),
          ),
        );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: InsightPage()),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    expect(find.text('本期到期 1 项，冻结 0 项'), findsOneWidget);
    await tester.tap(find.byTooltip('上一周'));
    await tester.pumpAndSettle();
    expect(find.text('本期没有到期任务，试试其他周期。'), findsOneWidget);
    await tester.tap(find.byTooltip('下一周'));
    await tester.pumpAndSettle();
    expect(find.text('本期到期 1 项，冻结 0 项'), findsOneWidget);
    await db.taskDao.editTask(id: 1, status: const Value(0));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    expect(find.text('0%'), findsOneWidget);
    await tester.tap(find.text('按月'));
    await tester.pumpAndSettle();
    expect(
      find.text('本期到期 ${start.month == DateTime.now().month ? 1 : 0} 项，冻结 0 项'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
  });

  testWidgets('loading, error and retry are explicit', (tester) async {
    final controller = StreamController<List<Task>>.broadcast();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await controller.close();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          insightTasksProvider.overrideWith((ref) => controller.stream),
        ],
        child: const MaterialApp(home: Scaffold(body: InsightPage())),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    controller.addError(StateError('offline'));
    await tester.pumpAndSettle();
    expect(find.text('回顾数据加载失败，请重试'), findsOneWidget);
    await tester.tap(find.text('重试'));
    await tester.pump();
    controller.add([]);
    await tester.pumpAndSettle();
    expect(find.text('本期没有到期任务，试试其他周期。'), findsOneWidget);
  });

  for (final dark in [false, true]) {
    testWidgets('narrow ${dark ? 'dark' : 'light'} page supports large text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            insightTasksProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(2)),
              child: child!,
            ),
            home: const Scaffold(body: InsightPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -1800));
      await tester.pumpAndSettle();
      expect(find.text('暂无记录'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
