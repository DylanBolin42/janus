import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart' hide Table;
import 'package:janus/models/task.dart';

import 'tag_tables.dart';
import 'task_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Tasks, Tags], daos: [TaskDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// 测试专用：注入内存数据库，避免依赖 drift_flutter 的平台插件连接。
  @visibleForTesting
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // v1 -> v2：新增 tags 表
      if (from < 2) {
        await m.createTable(tags);
      }
      // v2 -> v3：tasks 表新增 status 列（默认 0-未完成）
      if (from < 3) {
        await m.addColumn(tasks, tasks.status);
      }
    },
  );
}

@DriftAccessor(tables: [Tasks, Tags])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  // ----------------------- Task DB Operation Zone -------------------------
  /// 创建一个任务
  /// 输入： 标题，备注，DDL，EST，优先级，（tags），状态
  /// 无输出，id自增
  Future<int> createTask(TaskDraft draft) {
    return into(tasks).insert(
      TasksCompanion.insert(
        //TODO: 给所有相关方法添加Status字段
        status: Value(draft.status),
        title: draft.title,
        ddl: draft.ddl!,
        description: Value(draft.description),
        estHour: Value(draft.est?.hour),
        estMinute: Value(draft.est?.minute),
        priority: Value(draft.priority),
        tags: Value(draft.tags),
      ),
    );
  }

  /// 查询全部任务（按截止时间升序）
  /// 输出： List<Task>
  Future<List<Task>> getAllTasks() {
    return (select(tasks)..orderBy([(t) => OrderingTerm.asc(t.ddl)])).get();
  }

  /// 实时监听全部任务（含已完成，按截止时间升序），增删改后自动推送
  /// 输出： Stream<List<Task>>
  Stream<List<Task>> watchAllTasks() {
    return (select(tasks)..orderBy([(t) => OrderingTerm.asc(t.ddl)])).watch();
  }

  /// 实时监听未完成任务（status != 1，即排除已完成），按截止时间升序，增删改后自动推送。
  ///
  /// 首页任务列表使用此流：任务被滑动标记为完成后（status 变为 1）会自动从流中消失。
  /// 输出： `Stream<List<Task>>`
  Stream<List<Task>> watchIncompleteTasks() {
    return (select(tasks)
          ..where((t) => t.status.isNotValue(1))
          ..orderBy([(t) => OrderingTerm.asc(t.ddl)]))
        .watch();
  }

  /// 按优先级查询任务
  /// 输入： 优先级int值（0-无，1-低，2-中，3-高）
  // ignore: unintended_html_in_doc_comment
  /// 输出： List<Task>
  Future<List<Task>> getTaskByPriority(int priority) {
    return (select(tasks)
          ..where((t) => t.priority.equals(priority))
          ..orderBy([(t) => OrderingTerm.desc(t.ddl)]))
        .get();
  }

  /// 增量修改任务：只更新显式传入的字段，其余字段保持数据库原值不变。
  ///
  /// 输入：
  /// - [id]：目标任务 id（必填，定位行）
  /// - 其余参数默认 [Value.absent]（表示不修改该字段）
  /// - 可空列（description / est / tags）可传 `Value(null)` 显式清空
  /// 输出： 受影响行数；未传任何字段时为 0（空操作）
  Future<int> editTask({
    required int id,
    Value<int> status = const Value.absent(),
    Value<String> title = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<DateTime> ddl = const Value.absent(),
    Value<TimeOfDay?> est = const Value.absent(),
    Value<int> priority = const Value.absent(),
    Value<List<String>?> tags = const Value.absent(),
  }) {
    // 没有任何字段需要修改时直接返回 0，避免生成空 SET 的 UPDATE 语句
    if (!status.present &&
        !title.present &&
        !description.present &&
        !ddl.present &&
        !est.present &&
        !priority.present &&
        !tags.present) {
      return Future.value(0);
    }
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        status: status,
        title: title,
        description: description,
        ddl: ddl,
        // est 由「小时 + 分钟」两列组成，必须同时写入或同时保持原值
        estHour: est.present ? Value(est.value?.hour) : const Value.absent(),
        estMinute: est.present
            ? Value(est.value?.minute)
            : const Value.absent(),
        priority: priority,
        tags: tags,
      ),
    );
  }

  // ---------------------------- Tag DB Operation Zone --------------------------
  /// 创建一个标签
  /// 输入： 标签名
  /// 无输出，自动分配自增id
  Future<int> createTag(String name) {
    return into(tags).insert(TagsCompanion.insert(name: name));
  }

  /// 查询全部标签（按名称升序），供任务表单的标签下拉框使用。
  Future<List<Tag>> getAllTags() {
    return (select(tags)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }

  // ------------------------- Utility Zone (开发调试) -------------------------
  /// 清空全部任务
  Future<int> deleteAllTasks() => delete(tasks).go();

  /// 清空全部标签
  Future<int> deleteAllTags() => delete(tags).go();

  /// 清空全部数据（任务 + 标签），开发调试用
  Future<void> deleteAllData() async {
    await transaction(() async {
      await delete(tasks).go();
      await delete(tags).go();
    });
  }

  /// 填充示例数据（开发调试用）
  /// 返回本次插入的任务数；标签已存在时自动跳过（name 唯一约束）。
  Future<int> seedSampleData() async {
    // 以当前时间为基准生成相对 DDL，保证首页展示鲜活
    final now = DateTime.now();
    final today9 = DateTime(now.year, now.month, now.day, 9, 0);

    final sampleTags = const ['工作', '生活', '学习', '健康', '家庭'];
    final sampleTasks =
        <
          ({
            String title,
            String? description,
            DateTime ddl,
            int? estHour,
            int? estMinute,
            int priority,
            List<String> tags,
            int status,
          })
        >[
          (
            title: '完成项目答辩 PPT',
            description: '下午 3 点前交给导师终审',
            ddl: today9.add(const Duration(hours: 6)),
            estHour: 2,
            estMinute: 30,
            priority: 3,
            tags: const ['工作'],
            status: 0,
          ),
          (
            title: '买牛奶',
            description: '记得买两盒鲜牛奶',
            ddl: today9.add(const Duration(hours: 3)),
            estHour: 0,
            estMinute: 30,
            priority: 2,
            tags: const ['生活'],
            status: 0,
          ),
          (
            title: '阅读《思考，快与慢》30 分钟',
            description: null,
            ddl: today9.add(const Duration(days: 1)),
            estHour: 0,
            estMinute: 30,
            priority: 1,
            tags: const ['学习'],
            status: 2, // 已规划
          ),
          (
            title: '预约年度体检',
            description: '选一家离公司近的体检中心',
            ddl: today9.add(const Duration(days: 2)),
            estHour: 1,
            estMinute: 0,
            priority: 1,
            tags: const ['健康'],
            status: 0,
          ),
          (
            title: '给妈妈打电话',
            description: null,
            ddl: today9.add(const Duration(days: 3)),
            estHour: 0,
            estMinute: 15,
            priority: 0,
            tags: const ['家庭'],
            status: 0,
          ),
          (
            title: '整理桌面文件',
            description: '归档旧项目，清理回收站',
            ddl: today9.subtract(const Duration(days: 1)),
            estHour: 1,
            estMinute: 0,
            priority: 0,
            tags: const ['工作'],
            status: 1, // 已完成，展示完成态样式
          ),
        ];

    var inserted = 0;
    await transaction(() async {
      for (final name in sampleTags) {
        await into(tags).insert(
          TagsCompanion.insert(name: name),
          mode: InsertMode.insertOrIgnore,
        );
      }
      for (final t in sampleTasks) {
        await into(tasks).insert(
          TasksCompanion.insert(
            title: t.title,
            ddl: t.ddl,
            status: Value(t.status),
            description: Value(t.description),
            estHour: Value(t.estHour),
            estMinute: Value(t.estMinute),
            priority: Value(t.priority),
            tags: Value(t.tags),
          ),
        );
        inserted++;
      }
    });
    return inserted;
  }
}

QueryExecutor _openConnection() => driftDatabase(name: 'janus');
