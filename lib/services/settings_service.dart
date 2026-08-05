import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:janus/models/app_settings.dart';

/// Persistence layer for [AppSettings] using [shared_preferences].
///
/// Saves the settings as a JSON string under a single key,
/// so adding new fields is a no‑op for existing users.
class SettingsService {
  static const String _key = 'app_settings';
  static const String _apiKeyKey = 'ai_api_key';
  static const String _xorKey = 'janus_xor_key';

  String _xorCipher(String input) {
    if (input.isEmpty) return '';
    final List<int> result = [];
    final List<int> inputBytes = utf8.encode(input);
    final List<int> keyBytes = utf8.encode(_xorKey);
    for (int i = 0; i < inputBytes.length; i++) {
      result.add(inputBytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    return base64.encode(result);
  }

  String _xorDecipher(String base64Input) {
    if (base64Input.isEmpty) return '';
    try {
      final List<int> inputBytes = base64.decode(base64Input);
      final List<int> result = [];
      final List<int> keyBytes = utf8.encode(_xorKey);
      for (int i = 0; i < inputBytes.length; i++) {
        result.add(inputBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      return utf8.decode(result);
    } catch (_) {
      return '';
    }
  }

  /// Loads the obfuscated API Key from shared preferences.
  Future<String> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_apiKeyKey);
    if (raw == null) return '';
    return _xorDecipher(raw);
  }

  /// Persists the API Key obfuscated with XOR to shared preferences.
  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, _xorCipher(apiKey));
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
