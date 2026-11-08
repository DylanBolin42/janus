import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:janus/database/app_database.dart';
import 'package:janus/models/app_settings.dart';
import 'package:janus/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sync_backend.dart';

enum SyncPhase { idle, connecting, syncing, success, failed }

enum SyncAction { check, upload, download }

/// Full replacement snapshots deliberately avoid merging device-local task IDs.
class SnapshotStore {
  SnapshotStore(this.db, this.settings);
  final AppDatabase db;
  final SettingsService settings;

  // Sync/security configuration is device-local, never imported from a server.
  static const localKeys = {
    'syncEnabled',
    'syncMode',
    'syncTrigger',
    'syncDurationOnInterval',
    'rsaType',
    'useAppLock',
    'endPoint',
    'modelName',
  };

  // TODO(JANUS-19): Optional client-side authenticated encryption needs a
  // versioned envelope, audited AEAD/KDF implementation and multi-device key
  // recovery. Until those exist, snapshots contain plaintext task data.
  Future<String> export() async {
    final prefs = (await settings.load()).toJson()
      ..removeWhere((key, _) => localKeys.contains(key));
    return db.transaction(
      () async => jsonEncode({
        'version': 1,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'tasks': (await db.taskDao.getAllTasks())
            .map((t) => t.toJson())
            .toList(),
        'tags': (await db.taskDao.getAllTags()).map((t) => t.toJson()).toList(),
        'settings': prefs,
      }),
    );
  }

  Future<void> restore(String raw) async {
    // Decode and validate everything before touching either persistence layer.
    late List<Task> tasks;
    late List<Tag> tags;
    late AppSettings restored;
    final previous = await settings.load();
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      if (json['version'] != 1) throw const FormatException();
      DateTime.parse(json['createdAt'] as String);
      tasks = (json['tasks'] as List).map((t) {
        final row = Map<String, dynamic>.from(t as Map);
        // Drift's default serializer casts custom converter values directly.
        // JSON decoding yields List<dynamic>, so normalize before decoding.
        if (row['tags'] != null) {
          row['tags'] = List<String>.from(row['tags'] as List);
        }
        return Task.fromJson(row);
      }).toList();
      tags = (json['tags'] as List)
          .map((t) => Tag.fromJson(Map<String, dynamic>.from(t as Map)))
          .toList();
      if (tasks.map((t) => t.id).toSet().length != tasks.length ||
          tags.map((t) => t.id).toSet().length != tags.length ||
          tags.map((t) => t.name).toSet().length != tags.length ||
          tasks.any(
            (t) =>
                t.id < 1 ||
                t.title.trim().isEmpty ||
                ![-1, 0, 1, 2].contains(t.status) ||
                t.priority < 0 ||
                t.priority > 3 ||
                (t.estHour != null && (t.estHour! < 0 || t.estHour! > 23)) ||
                (t.estMinute != null &&
                    (t.estMinute! < 0 || t.estMinute! > 59)),
          ) ||
          tags.any((t) => t.id < 1 || t.name.trim().isEmpty)) {
        throw const FormatException();
      }
      final remote = Map<String, dynamic>.from(json['settings'] as Map)
        ..removeWhere((key, _) => localKeys.contains(key));
      restored = AppSettings.fromJson({...previous.toJson(), ...remote});
    } catch (_) {
      throw const SyncFailure('快照格式无效或版本不兼容，本地数据未修改');
    }
    // Preferences are written inside the DB transaction; compensate on failure.
    try {
      await db.transaction(() async {
        await db.delete(db.tasks).go();
        await db.delete(db.tags).go();
        for (final task in tasks) {
          await db.into(db.tasks).insert(task.toCompanion(false));
        }
        for (final tag in tags) {
          await db.into(db.tags).insert(tag.toCompanion(false));
        }
        await settings.save(restored);
      });
    } catch (_) {
      await settings.save(previous);
      throw const SyncFailure('恢复失败，已回滚本地数据，请重试');
    }
  }
}

class SyncService extends ChangeNotifier {
  // All service/provider instances in this application isolate share the same
  // local database and preferences. Acquire synchronously before the first await.
  // This is not a cross-device or cross-process WebDAV conflict lock.
  static bool _operationInFlight = false;
  SyncService({required this.backend, required this.store});
  final SyncBackend Function(SyncConfig) backend;
  final SnapshotStore Function() store;
  SyncPhase phase = SyncPhase.idle;
  SyncAction? lastAction;
  DateTime? lastSync;
  String message = '尚未同步';
  bool get busy => phase == SyncPhase.connecting || phase == SyncPhase.syncing;
  bool _disposed = false;
  void _update(SyncPhase value, String text) {
    phase = value;
    message = text;
    if (!_disposed) notifyListeners();
  }

  Future<void> refresh() async {
    if (busy) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      lastSync = DateTime.tryParse(prefs.getString('sync.lastSuccess') ?? '');
      if (!_disposed) notifyListeners();
    } catch (_) {
      _update(SyncPhase.failed, '无法读取上次同步时间，请重试');
    }
  }

  Future<void> run(SyncAction action, SyncConfig config) async {
    if (busy) return;
    lastAction = action;
    if (_operationInFlight) {
      _update(SyncPhase.failed, '另一个同步操作正在运行，请稍后重试');
      return;
    }
    _operationInFlight = true;
    try {
      _update(SyncPhase.connecting, '正在连接服务器');
      config.directory;
      final remote = backend(config);
      await remote.verify();
      if (action == SyncAction.check) {
        _update(SyncPhase.success, '连接验证通过，尚未传输数据');
        return;
      }
      _update(
        SyncPhase.syncing,
        action == SyncAction.upload ? '正在上传快照' : '正在下载并恢复快照',
      );
      if (action == SyncAction.upload) {
        await remote.upload(await store().export());
      } else {
        await store().restore(await remote.download());
      }
      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setString('sync.lastSuccess', now.toIso8601String())) {
        throw const SyncFailure('传输完成，但保存同步时间失败，请刷新后检查');
      }
      lastSync = now;
      _update(
        SyncPhase.success,
        action == SyncAction.upload ? '快照上传完成' : '快照恢复完成',
      );
    } on SyncFailure catch (error) {
      _update(SyncPhase.failed, error.message);
    } catch (_) {
      _update(SyncPhase.failed, '同步失败，请检查配置、存储空间后重试');
    } finally {
      _operationInFlight = false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
