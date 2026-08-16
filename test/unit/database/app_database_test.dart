import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/database/app_database.dart';
import 'package:janus/database/task_tables.dart';
import 'package:janus/models/task.dart';

void main() {
  late AppDatabase db;
  late TaskDao dao;

  /// 每个测试独立的内存数据库。
  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.taskDao;
    addTearDown(() async => db.close());
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 表定义
  // ─────────────────────────────────────────────────────────────────────────
  group('表定义', () {
    test('tasks 与 tags 表存在', () {
      expect(db.tasks.actualTableName, 'tasks');
      expect(db.tags.actualTableName, 'tags');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TaskDao.createTask
  // ─────────────────────────────────────────────────────────────────────────
  group('TaskDao.createTask', () {
    test('插入任务并返回自增 id', () async {
      final id = await dao.createTask(
        TaskDraft(title: '买牛奶', ddl: DateTime(2026, 8, 18, 20)),
      );

      expect(id, isPositive);

      final rows = await db.select(db.tasks).get();
      expect(rows, hasLength(1));
      expect(rows.single.title, '买牛奶');
      expect(rows.single.ddl, DateTime(2026, 8, 18, 20));
    });

    test('可插入全字段任务并读回', () async {
      await dao.createTask(
        TaskDraft(
          title: '写周报',
          description: '汇总本周进展',
          ddl: DateTime(2026, 8, 20, 9, 30),
          est: const TimeOfDay(hour: 2, minute: 30),
          priority: 3,
          tags: const ['工作', '文档'],
        ),
      );

      final row = (await db.select(db.tasks).get()).single;
      expect(row.title, '写周报');
      expect(row.description, '汇总本周进展');
      expect(row.estHour, 2);
      expect(row.estMinute, 30);
      expect(row.priority, 3);
      expect(row.tags, ['工作', '文档']);
    });

    test('description / est / tags 缺省时保存为空', () async {
      await dao.createTask(
        TaskDraft(title: '极简任务', ddl: DateTime(2026, 8, 18)),
      );

      final row = (await db.select(db.tasks).get()).single;
      expect(row.description, isNull);
      expect(row.estHour, isNull);
      expect(row.estMinute, isNull);
      expect(row.priority, 0); // 默认值
      expect(row.tags, isEmpty); // TaskDraft 默认 tags 为空列表
    });

    test('空标题插入会触发长度约束', () async {
      final draft = TaskDraft(title: '', ddl: DateTime(2026, 8, 18));

      await expectLater(dao.createTask(draft), throwsA(anything));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TaskDao.createTag / getAllTags
  // ─────────────────────────────────────────────────────────────────────────
  group('TaskDao.createTag / getAllTags', () {
    test('创建标签并查询（按名称升序）', () async {
      await dao.createTag('工作');
      await dao.createTag('生活');
      await dao.createTag('学习');

      final tags = await dao.getAllTags();

      expect(tags.map((t) => t.name).toList(), ['学习', '工作', '生活']);
    });

    test('无标签时返回空列表', () async {
      expect(await dao.getAllTags(), isEmpty);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TagConverter
  // ─────────────────────────────────────────────────────────────────────────
  group('TagConverter', () {
    const converter = TagConverter();

    test('toSql 将列表序列化为 JSON 字符串', () {
      expect(converter.toSql(['a', 'b']), '["a","b"]');
      expect(converter.toSql(const []), '[]');
    });

    test('fromSql 将 JSON 字符串反序列化为列表', () {
      expect(converter.fromSql('["a","b"]'), ['a', 'b']);
      expect(converter.fromSql('[]'), isEmpty);
    });

    test('fromSql / toSql 往返一致', () {
      const tags = ['工作', '文档', '学习'];

      expect(converter.fromSql(converter.toSql(tags)), tags);
    });
  });
}
