import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/database/app_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  return AppDatabase();
}

@Riverpod(keepAlive: true)
TaskDao taskDao(Ref ref) {
  return ref.watch(appDatabaseProvider).taskDao;
}

/// 全部任务的实时流：数据库增删改后自动刷新，供首页任务列表使用。
///
/// 手写 provider（不经过 riverpod_generator 代码生成）：drift 生成的 `Task`
/// 定义在 `app_database.g.dart`（part 文件），代码生成器在同一次构建里无法
/// 解析它（InvalidTypeException），手写即可绕过该限制。
final allTasksProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskDaoProvider).watchAllTasks();
});
