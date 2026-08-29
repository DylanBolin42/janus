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
  // EST is divided to minute and hour
  IntColumn get estHour => integer().nullable()();
  IntColumn get estMinute => integer().nullable()();
  // ---
  IntColumn get priority => integer().withDefault(const Constant(0))();
  TextColumn get tags => text().map(const TagConverter()).nullable()();
}
