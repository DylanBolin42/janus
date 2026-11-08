import 'dart:convert';

import 'package:drift/drift.dart';

class TagConverter extends TypeConverter<List<String>, String> {
  const TagConverter();

  @override
  List<String> fromSql(String fromDB) =>
      (jsonDecode(fromDB) as List).cast<String>();

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Status定义
  /// 0  -> 未完成
  /// 1  -> 已完成
  /// 2  -> 已规划
  /// -1 -> 已冻结
  /// 是否逾期交由Status和DDL与当前时间的比较运算后得出
  IntColumn get status => integer().withDefault(const Constant(0))();
  TextColumn get title => text().withLength(min: 1)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get ddl => dateTime()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// Actual consumed whole minutes, independently of EST. Null means unknown.
  IntColumn get usedTime =>
      integer().nullable().customConstraint('CHECK (used_time >= 0)')();

  /// Null on legacy records: an absent historical graph is not confirmed empty.
  BoolColumn get dependencyGraphKnown => boolean().nullable()();
  BoolColumn get priorityExplicit => boolean().nullable()();
  // EST is a duration: estHour * 60 + estMinute, in minutes.
  IntColumn get estHour => integer().nullable()();
  IntColumn get estMinute => integer().nullable()();
  // ---
  IntColumn get priority => integer().withDefault(const Constant(0))();
  TextColumn get tags => text().map(const TagConverter()).nullable()();
}

/// Shared lifecycle whitelist used by every status-writing entry point.
class TaskLifecycle {
  static const transitions = <int, Set<int>>{
    0: {1, 2, -1},
    2: {0, 1, -1},
    -1: {0, 2},
    1: {0},
  };
  static void requireTransition(int from, int to) {
    if (!(transitions[from]?.contains(to) ?? false)) {
      throw StateError('Illegal task transition: $from -> $to');
    }
  }
}
