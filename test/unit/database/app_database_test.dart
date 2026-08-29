import 'package:drift/drift.dart' show Value;
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
        TaskDraft(status: 0, title: '买牛奶', ddl: DateTime(2026, 8, 18, 20)),
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
          status: 0,
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
        TaskDraft(title: '极简任务', ddl: DateTime(2026, 8, 18), status: 0),
      );

      final row = (await db.select(db.tasks).get()).single;
      expect(row.description, isNull);
      expect(row.estHour, isNull);
      expect(row.estMinute, isNull);
      expect(row.priority, 0); // 默认值
      expect(row.tags, isEmpty); // TaskDraft 默认 tags 为空列表
    });

    test('空标题插入会触发长度约束', () async {
      final draft = TaskDraft(title: '', ddl: DateTime(2026, 8, 18), status: 0);

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

  // ─────────────────────────────────────────────────────────────────────────
  // TaskDao.seedSampleData / deleteAllData（开发调试用）
  // ─────────────────────────────────────────────────────────────────────────
  group('TaskDao.seedSampleData / deleteAllData', () {
    test('填充示例数据：插入标签与任务并返回任务数', () async {
      final count = await dao.seedSampleData();

      expect(count, 6);

      final tags = await dao.getAllTags();
      expect(tags.map((t) => t.name).toSet(), {'工作', '生活', '学习', '健康', '家庭'});

      final tasks = await dao.getAllTasks();
      expect(tasks, hasLength(6));
      expect(tasks.map((t) => t.title), contains('买牛奶'));
      expect(tasks.map((t) => t.priority), contains(3));
      expect(tasks.map((t) => t.status).toSet(), {0, 1, 2});
    });

    test('重复填充：标签自动跳过（唯一约束），任务会追加', () async {
      await dao.seedSampleData();
      final count = await dao.seedSampleData();

      expect(count, 6); // 再次插入 6 条任务
      expect(await dao.getAllTags(), hasLength(5)); // 标签不重复
      expect(await dao.getAllTasks(), hasLength(12));
    });

    test('deleteAllData 清空任务与标签', () async {
      await dao.seedSampleData();

      await dao.deleteAllData();

      expect(await dao.getAllTasks(), isEmpty);
      expect(await dao.getAllTags(), isEmpty);
    });

    test('deleteAllTasks / deleteAllTags 可单独清空', () async {
      await dao.seedSampleData();

      expect(await dao.deleteAllTasks(), 6);
      expect(await dao.getAllTasks(), isEmpty);
      // 任务清空不影响标签
      expect(await dao.getAllTags(), hasLength(5));

      expect(await dao.deleteAllTags(), 5);
      expect(await dao.getAllTags(), isEmpty);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TaskDao.editTask（增量更新：只改显式传入的字段）
  // ─────────────────────────────────────────────────────────────────────────
  group('TaskDao.editTask', () {
    test('只更新传入字段，其余字段保持原值', () async {
      await dao.seedSampleData();
      final target = (await dao.getAllTasks()).firstWhere(
        (t) => t.title == '完成项目答辩 PPT',
      );

      // 只传入 status，其余字段一律不动
      await dao.editTask(id: target.id, status: const Value(1));

      final after = await (db.select(
        db.tasks,
      )..where((t) => t.id.equals(target.id))).getSingle();
      expect(after.status, 1);
      expect(after.title, target.title);
      expect(after.description, target.description);
      expect(after.ddl, target.ddl);
      expect(after.estHour, target.estHour);
      expect(after.estMinute, target.estMinute);
      expect(after.priority, target.priority);
      expect(after.tags, target.tags);
    });

    test('不传任何字段时数据库行完全不变', () async {
      await dao.seedSampleData();
      final target = (await dao.getAllTasks()).first;

      await dao.editTask(id: target.id);

      final after = await (db.select(
        db.tasks,
      )..where((t) => t.id.equals(target.id))).getSingle();
      expect(after.title, target.title);
      expect(after.description, target.description);
      expect(after.ddl, target.ddl);
      expect(after.estHour, target.estHour);
      expect(after.estMinute, target.estMinute);
      expect(after.priority, target.priority);
      expect(after.status, target.status);
      expect(after.tags, target.tags);
    });

    test('可显式清空可空列（description）', () async {
      await dao.seedSampleData();
      final target = (await dao.getAllTasks()).firstWhere(
        (t) => t.title == '完成项目答辩 PPT',
      );
      expect(target.description, isNotNull);

      await dao.editTask(
        id: target.id,
        title: const Value('改后标题'),
        description: const Value(null),
      );

      final after = await (db.select(
        db.tasks,
      )..where((t) => t.id.equals(target.id))).getSingle();
      expect(after.title, '改后标题');
      expect(after.description, isNull);
      // 未传的字段保持原值
      expect(after.status, target.status);
      expect(after.priority, target.priority);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TaskDao.watchIncompleteTasks（首页任务流：滑动完成即从列表消失）
  // ─────────────────────────────────────────────────────────────────────────
  group('TaskDao.watchIncompleteTasks', () {
    test('默认排除已完成任务（status=1）', () async {
      await dao.seedSampleData();

      // 示例数据里 6 条任务，其中「整理桌面文件」已完成
      final all = await dao.getAllTasks();
      expect(all.where((t) => t.status == 1).map((t) => t.title), ['整理桌面文件']);

      final streamTasks = await dao.watchIncompleteTasks().first;
      expect(streamTasks, hasLength(5));
      expect(streamTasks.map((t) => t.title), isNot(contains('整理桌面文件')));
    });

    test('任务被标记完成后自动从流中消失', () async {
      await dao.seedSampleData();

      final before = await dao.watchIncompleteTasks().first;
      expect(before, hasLength(5));
      final target = before.first;

      // 模拟首页右滑完成：增量更新，只把 status 置为 1
      await dao.editTask(id: target.id, status: const Value(1));

      final after = await dao.watchIncompleteTasks().first;
      expect(after.map((t) => t.id), isNot(contains(target.id)));
      expect(after, hasLength(4));
    });
  });
}
