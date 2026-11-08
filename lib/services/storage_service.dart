import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:janus/database/app_database.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Extension point for future storage strategies and synchronization.
abstract interface class StorageRepository {
  Future<StorageStatistics> statistics();
  Future<File> exportSnapshot();
  Future<StorageSnapshot> readSnapshot(File file);
  Future<void> restore(StorageSnapshot snapshot);
  Future<void> clear();
}

class StorageStatistics {
  const StorageStatistics(this.tasks, this.tags, this.completed, this.bytes);
  final int tasks, tags, completed;

  /// SQLite database plus any current WAL/SHM files; null when unavailable.
  final int? bytes;
}

/// JSON protocol v1. Settings and external assets are intentionally excluded.
class StorageSnapshot {
  StorageSnapshot._(this.tasks, this.tags);
  static const version = 1;
  final List<Task> tasks;
  final List<Tag> tags;

  factory StorageSnapshot.parse(String source, int schemaVersion) {
    dynamic root;
    try {
      root = jsonDecode(source);
    } on FormatException {
      throw const FormatException('文件损坏：不是有效的 JSON');
    }
    if (root is! Map<String, dynamic>) {
      throw const FormatException('快照根节点必须为对象');
    }
    if (root['formatVersion'] is! int || root['formatVersion'] != version) {
      throw const FormatException('不支持的快照版本');
    }
    if (root['schemaVersion'] is! int ||
        root['schemaVersion'] != schemaVersion) {
      throw const FormatException('数据库版本不匹配');
    }
    if (root['createdAt'] is! String ||
        DateTime.tryParse(root['createdAt'] as String) == null) {
      throw const FormatException('createdAt 缺失或无效');
    }
    List<Map<String, dynamic>> rows(String key, List<String> fields) {
      final value = root[key];
      if (value is! List) throw FormatException('$key 缺失或不是数组');
      return value.map((row) {
        if (row is! Map<String, dynamic>) {
          throw FormatException('$key 包含无效记录');
        }
        for (final field in fields) {
          if (!row.containsKey(field)) {
            throw FormatException('$key 缺少字段 $field');
          }
        }
        return row;
      }).toList();
    }

    final taskRows = rows('tasks', [
      'id',
      'status',
      'title',
      'description',
      'ddl',
      'estHour',
      'estMinute',
      'priority',
      'tags',
    ]);
    final tagRows = rows('tags', ['id', 'name']);
    try {
      final tasks = taskRows.map((row) {
        final rawTags = row['tags'];
        if (rawTags != null &&
            (rawTags is! List || rawTags.any((t) => t is! String))) {
          throw const FormatException('tasks.tags 必须为字符串数组或 null');
        }
        for (final key in ['id', 'status', 'priority', 'ddl']) {
          if (row[key] is! int) throw FormatException('tasks.$key 必须为整数');
        }
        for (final key in ['estHour', 'estMinute']) {
          if (row[key] != null && row[key] is! int) {
            throw FormatException('tasks.$key 必须为整数或 null');
          }
        }
        return Task.fromJson({
          ...row,
          'tags': rawTags == null ? null : List<String>.from(rawTags as List),
        });
      }).toList();
      final tags = tagRows.map(Tag.fromJson).toList();
      final ids = <int>{};
      for (final t in tasks) {
        if (t.id <= 0 ||
            !ids.add(t.id) ||
            t.title.isEmpty ||
            ![-1, 0, 1, 2].contains(t.status) ||
            t.priority < 0 ||
            t.priority > 3 ||
            (t.estHour == null) != (t.estMinute == null) ||
            (t.estHour != null && (t.estHour! < 0 || t.estHour! > 23)) ||
            (t.estMinute != null && (t.estMinute! < 0 || t.estMinute! > 59))) {
          throw const FormatException('tasks 包含无效值或重复 ID');
        }
      }
      ids.clear();
      final names = <String>{};
      for (final tag in tags) {
        if (tag.id <= 0 ||
            !ids.add(tag.id) ||
            tag.name.isEmpty ||
            !names.add(tag.name)) {
          throw const FormatException('tags 包含无效值、重复 ID 或名称');
        }
      }
      return StorageSnapshot._(
        List.unmodifiable(tasks),
        List.unmodifiable(tags),
      );
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('记录字段类型无效');
    }
  }
}

/// Extends JANUS-15's transactional statistics/clear operations.
class StorageService implements StorageRepository {
  StorageService(this.database, {Future<Directory> Function()? documents})
    : documents = documents ?? getApplicationDocumentsDirectory;
  final AppDatabase database;
  final Future<Directory> Function() documents;

  Future<Directory> snapshotDirectory() async {
    final dir = Directory(p.join((await documents()).path, 'janus_snapshots'));
    return dir.create(recursive: true);
  }

  Future<List<File>> snapshots() async {
    final dir = await snapshotDirectory();
    final files = await dir
        .list()
        .where((f) => f is File && f.path.endsWith('.json'))
        .cast<File>()
        .toList();
    files.sort((a, b) => b.path.compareTo(a.path));
    return files;
  }

  @override
  Future<StorageStatistics> statistics() async {
    final counts = await database.transaction(() async {
      final taskCount = database.tasks.id.count();
      final tagCount = database.tags.id.count();
      final completedCount = database.tasks.id.count(
        filter: database.tasks.status.equals(1),
      );
      final tasks = await (database.selectOnly(
        database.tasks,
      )..addColumns([taskCount, completedCount])).getSingle();
      final tags = await (database.selectOnly(
        database.tags,
      )..addColumns([tagCount])).getSingle();
      return (
        tasks.read(taskCount) ?? 0,
        tags.read(tagCount) ?? 0,
        tasks.read(completedCount) ?? 0,
      );
    });
    int? bytes;
    // Ask SQLite for its actual filename rather than assuming the platform path.
    try {
      final rows = await database.customSelect('PRAGMA database_list').get();
      final path = rows
          .firstWhere((r) => r.read<String>('name') == 'main')
          .read<String>('file');
      if (path.isNotEmpty && await File(path).exists()) {
        var total = 0;
        for (final suffix in ['', '-wal', '-shm']) {
          final file = File('$path$suffix');
          if (await file.exists()) total += await file.length();
        }
        bytes = total;
      }
    } on FileSystemException {
      // Record counts remain usable when platform file metadata is inaccessible.
    }
    return StorageStatistics(counts.$1, counts.$2, counts.$3, bytes);
  }

  @override
  Future<File> exportSnapshot() async {
    final data = await database.transaction(
      () async => {
        'formatVersion': StorageSnapshot.version,
        'schemaVersion': database.schemaVersion,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'tasks': (await database.select(database.tasks).get())
            .map((t) => t.toJson())
            .toList(),
        'tags': (await database.select(database.tags).get())
            .map((t) => t.toJson())
            .toList(),
      },
    );
    final dir = await snapshotDirectory();
    final target = File(
      p.join(
        dir.path,
        'janus_${DateTime.now().toUtc().microsecondsSinceEpoch}.json',
      ),
    );
    final temp = File('${target.path}.tmp');
    try {
      await temp.writeAsString(jsonEncode(data), flush: true);
      return await temp.rename(target.path);
    } catch (_) {
      if (await temp.exists()) await temp.delete();
      rethrow;
    }
  }

  @override
  Future<StorageSnapshot> readSnapshot(File file) async =>
      StorageSnapshot.parse(await file.readAsString(), database.schemaVersion);

  @override
  Future<void> restore(StorageSnapshot snapshot) =>
      database.transaction(() async {
        await database.delete(database.tasks).go();
        await database.delete(database.tags).go();
        for (final tag in snapshot.tags) {
          await database.into(database.tags).insert(tag);
        }
        for (final task in snapshot.tasks) {
          await database.into(database.tasks).insert(task);
        }
      });

  /// Keep schema/settings intact and notify Drift's live queries.
  @override
  Future<void> clear() => database.taskDao.deleteAllData();
}
