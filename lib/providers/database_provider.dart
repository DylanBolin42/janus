import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/database/app_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/cardo/cardo_config.dart';
import '../services/cardo/cardo_data_service.dart';
import '../services/cardo/cardo_scoring_service.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  return AppDatabase();
}

@Riverpod(keepAlive: true)
TaskDao taskDao(Ref ref) {
  return ref.watch(appDatabaseProvider).taskDao;
}

/// 首页任务列表的实时流：仅包含未完成任务（status != 1），数据库增删改后自动刷新。
///
/// 手写 provider（不经过 riverpod_generator 代码生成）：drift 生成的 `Task`
/// 定义在 `app_database.g.dart`（part 文件），代码生成器在同一次构建里无法
/// 解析它（InvalidTypeException），手写即可绕过该限制。
final inboxTasksProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskDaoProvider).watchIncompleteTasks();
});

/// Shared scoring entry point for UI, scheduling and other callers.
final cardoConfigProvider = Provider<CardoConfigService>((ref) {
  final service = CardoConfigService();
  ref.onDispose(service.dispose);
  unawaited(
    SharedPreferencesAsync().getString('cardo.configPath').then((path) async {
      if (path != null && service.attemptedSource == null) {
        await service.watchFile(path);
      }
    }),
  );
  return service;
});
final cardoScoringProvider = Provider<CardoScoringService>(
  (ref) => CardoScoringService(ref.watch(cardoConfigProvider)),
);
final cardoDataProvider = Provider<CardoDataService>(
  (ref) => CardoDataService(
    ref.watch(appDatabaseProvider),
    ref.watch(cardoScoringProvider),
  ),
);
final cardoResultsProvider = StreamProvider<List<CardoResult>>(
  (ref) => ref.watch(cardoDataProvider).watch(),
);
