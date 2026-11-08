import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:janus/models/app_settings.dart';

/// Persistence layer for [AppSettings] using [shared_preferences].
class SettingsService {
  static const String _key = 'app_settings';
  static const String corruptBackupKey = 'corrupt_settings_backup';

  /// Remains visible for this session, even after saving recovered settings.
  bool recoveredCorruptSettings = false;
  bool _loaded = false;

  /// Invalid fields use defaults; valid fields are retained. Before returning
  /// recovered values, preserve the original data. Backup failures block edits.
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final original = prefs.get(_key);
    if (original == null) {
      _loaded = true;
      return const AppSettings();
    }
    var corrupt = false;
    final valid = <String, dynamic>{};
    try {
      final decoded = jsonDecode(original as String) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        try {
          AppSettings.fromJson({entry.key: entry.value});
          valid[entry.key] = entry.value;
        } catch (_) {
          corrupt = true;
        }
      }
    } catch (_) {
      corrupt = true;
    }
    if (corrupt) {
      final raw = original is String ? original : jsonEncode(original);
      if (!await prefs.setString(corruptBackupKey, raw)) {
        throw StateError('设置损坏且备份失败，已停止加载和保存以保护原数据');
      }
      recoveredCorruptSettings = true;
    }
    _loaded = true;
    return AppSettings.fromJson(valid);
  }

  /// Persists [settings] only after existing data has been checked and backed up.
  Future<void> save(AppSettings settings) async {
    if (!_loaded) await load();
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString(_key, jsonEncode(settings.toJson()));
    if (!saved) throw StateError('Unable to save app settings');
  }
}
