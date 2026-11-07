import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/database/app_database.dart';
import 'package:janus/models/task.dart';
import 'package:janus/services/storage_service.dart';

void main() {
  test(
    'statistics reflect stored tasks and clear preserves a usable schema',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final service = StorageService(database);
      expect(await service.statistics(), (tasks: 0, tags: 0));
      await database.taskDao.createTask(
        TaskDraft(status: 0, title: 'test', ddl: DateTime(2026)),
      );
      await database
          .into(database.tags)
          .insert(TagsCompanion.insert(name: 'work'));
      expect(await service.statistics(), (tasks: 1, tags: 1));
      await service.clear();
      expect(await service.statistics(), (tasks: 0, tags: 0));
      await database.taskDao.createTask(
        TaskDraft(status: 0, title: 'after clear', ddl: DateTime(2026)),
      );
      expect((await service.statistics()).tasks, 1);
    },
  );
}
