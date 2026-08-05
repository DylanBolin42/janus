import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:janus/models/app_settings.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persistence layer for [AppSettings] using [shared_preferences] and [flutter_secure_storage].
///
/// Saves the settings as a JSON string under a single key,
/// so adding new fields is a no‑op for existing users.
class SettingsService {
  static const String _key = 'app_settings';
  static const String _apiKeySecKey = 'ai_api_key_secure';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Loads the AI API key from secure storage.
  Future<String> getAiApiKey() async {
    try {
      return await _secureStorage.read(key: _apiKeySecKey) ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Persists the AI API key to secure storage.
  Future<void> saveAiApiKey(String apiKey) async {
    try {
      if (apiKey.isEmpty) {
        await _secureStorage.delete(key: _apiKeySecKey);
      } else {
        await _secureStorage.write(key: _apiKeySecKey, value: apiKey);
      }
    } catch (_) {}
  }

  /// Loads [AppSettings] from shared preferences.
  /// Returns the default [AppSettings] if nothing is stored yet
  /// or if the stored JSON is corrupt.
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(settings.toJson()));
  }
}
