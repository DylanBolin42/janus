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
