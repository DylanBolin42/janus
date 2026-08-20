import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
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
        status: const Value(0),
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

  /// 实时监听全部任务（按截止时间升序），增删改后自动推送
  /// 输出： Stream<List<Task>>
  Stream<List<Task>> watchAllTasks() {
    return (select(tasks)..orderBy([(t) => OrderingTerm.asc(t.ddl)])).watch();
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

  /// 修改一个任务的某一属性或某些属性
  /// 输入： 一个带有不同值的Task，但是包含相同的id
  /// 输出： 无输出
  Future<int> editTask(TaskDraft newVer) {
    return (update(tasks)..where((t) => t.id.equals(newVer.id!))).write(
      TasksCompanion(
        title: Value(newVer.title),
        status: Value(newVer.status),
        description: Value(newVer.description),
        ddl: Value(newVer.ddl!),
        estHour: Value(newVer.est?.hour),
        estMinute: Value(newVer.est?.minute),
        priority: Value(newVer.priority),
        tags: Value(newVer.tags),
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
}

QueryExecutor _openConnection() => driftDatabase(name: 'janus');
