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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // v1 -> v2：新增 tags 表
      if (from < 2) {
        await m.createTable(tags);
      }
    },
  );
}

@DriftAccessor(tables: [Tasks, Tags])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  Future<int> createTask(TaskDraft draft) {
    return into(tasks).insert(
      TasksCompanion.insert(
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

  Future<int> createTag(String name) {
    return into(tags).insert(TagsCompanion.insert(name: name));
  }

  /// 查询全部标签（按名称升序），供任务表单的标签下拉框使用。
  Future<List<Tag>> getAllTags() {
    return (select(tags)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }
}

QueryExecutor _openConnection() => driftDatabase(name: 'janus');
