import 'package:drift/drift.dart';
import 'package:janus/database/app_database.dart';

/// Database operations exposed by the storage settings page.
class StorageService {
  StorageService(this.database);

  final AppDatabase database;

  Future<({int tasks, int tags})> statistics() async {
    return database.transaction(() async {
      final taskCount = database.tasks.id.count();
      final tagCount = database.tags.id.count();
      final tasks = await (database.selectOnly(
        database.tasks,
      )..addColumns([taskCount])).getSingle();
      final tags = await (database.selectOnly(
        database.tags,
      )..addColumns([tagCount])).getSingle();
      return (
        tasks: tasks.read(taskCount) ?? 0,
        tags: tags.read(tagCount) ?? 0,
      );
    });
  }

  /// Keep schema and settings intact; invalidate live queries through Drift.
  Future<void> clear() => database.transaction(() async {
    await database.delete(database.tasks).go();
    await database.delete(database.tags).go();
  });
}
