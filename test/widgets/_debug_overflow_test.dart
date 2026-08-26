import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/database/app_database.dart';
import 'package:janus/models/task.dart';
import 'package:janus/pages/InboxPage/inbox_page.dart';
import 'package:janus/providers/database_provider.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('task card renders at rest — check overflows', (tester) async {
    await db.taskDao.createTask(
      TaskDraft(
        title: '测试任务',
        ddl: DateTime(2026, 8, 27, 9),
        est: const TimeOfDay(hour: 9, minute: 0),
      ),
    );
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: InboxPage()),
      ),
    );
    await tester.pumpAndSettle();

    final e1 = tester.takeException();
    debugPrint('exception after settle: $e1');
  });
}
