import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/database/app_database.dart';
import 'package:janus/pages/SettingPage/developer_entrance.dart';
import 'package:janus/providers/database_provider.dart';

void main() {
  late AppDatabase db;
  late TaskDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.taskDao;
  });

  tearDown(() async {
    await db.close();
  });

  Widget wrap() {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: DeveloperEntrance()),
    );
  }

  testWidgets('删除所有数据：数据清空且不抛异常', (tester) async {
    await dao.seedSampleData();
    expect(await dao.getAllTasks(), hasLength(6));

    await tester.pumpWidget(wrap());
    await tester.pump();

    // 点击「删除所有数据」
    await tester.tap(find.text('删除所有数据'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // 数据应被清空
    expect(await dao.getAllTasks(), isEmpty);
    expect(await dao.getAllTags(), isEmpty);

    // GlassScaffold 内部是 CupertinoPageScaffold（无 Material Scaffold），
    // 因此不能用 ScaffoldMessenger.showSnackBar；改用 GlassToast 后不应有任何异常。
    expect(tester.takeException(), isNull);
  });
}
