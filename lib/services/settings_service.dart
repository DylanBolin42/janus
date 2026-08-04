import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:janus/models/app_settings.dart';

/// Persistence layer for [AppSettings] using [shared_preferences].
///
/// Saves the settings as a JSON string under a single key,
/// so adding new fields is a no‑op for existing users.
class SettingsService {
  static const String _key = 'app_settings';
  SharedPreferences? _prefs;

  /// Retrieves the [SharedPreferences] instance, using a cached instance
  /// if already loaded to avoid setup overhead on consecutive calls.
  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Loads [AppSettings] from shared preferences.
  /// Returns the default [AppSettings] if nothing is stored yet
  /// or if the stored JSON is corrupt.
  Future<AppSettings> load() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_key);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Corrupt data → reset to defaults
      return const AppSettings();
    }
  }

  /// Persists [settings] to shared preferences.
  Future<void> save(AppSettings settings) async {
    final prefs = await _getPrefs();
    await prefs.setString(_key, jsonEncode(settings.toJson()));
  }
}
