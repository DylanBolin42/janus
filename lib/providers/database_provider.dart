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
