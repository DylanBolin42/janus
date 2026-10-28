import 'package:drift/native.dart';
import 'package:expandable_richtext/expandable_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/database/app_database.dart';
import 'package:janus/pages/InboxPage/inbox_page.dart';
import 'package:janus/providers/database_provider.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    // 内存数据库：避免 drift_flutter 在测试环境创建真实连接遗留 pending timer
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('InboxPage 渲染任务列表', (tester) async {
    final testTask = Task(
      id: 1,
      title: '测试隔离列表任务',
      description: '任务描述内容',
      status: 0,
      priority: 1,
      ddl: DateTime(2026, 8, 27, 9, 30),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inboxTasksProvider.overrideWith((ref) => Stream.value([testTask])),
        ],
        child: const MaterialApp(home: InboxPage()),
      ),
    );
    await tester.pump();

    expect(find.text('测试隔离列表任务'), findsOneWidget);
    expect(find.byType(ExpandableRichText), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
