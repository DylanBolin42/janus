import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:janus/models/app_settings.dart';

/// Persistence layer for [AppSettings] using [shared_preferences].
///
/// Saves the settings as a JSON string under a single key,
/// so adding new fields is a no‑op for existing users.
class SettingsService {
  static const String _key = 'app_settings';
  static const String _apiKey = 'ai_api_key';
  static const String _xorKey = 'janus_security_key_2025';

  /// Loads the API key securely by reading it from SharedPreferences and deciphering it.
  Future<String> loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final obfuscated = prefs.getString(_apiKey);
    if (obfuscated == null || obfuscated.isEmpty) return '';
    return _xorDecipher(obfuscated, _xorKey);
  }

  /// Persists the API key securely by obfuscating it and saving to SharedPreferences.
  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    if (apiKey.isEmpty) {
      await prefs.remove(_apiKey);
    } else {
      final obfuscated = _xorCipher(apiKey, _xorKey);
      await prefs.setString(_apiKey, obfuscated);
    }
  }

  String _xorCipher(String input, String key) {
    if (input.isEmpty || key.isEmpty) return input;
    final inputCodeUnits = utf8.encode(input);
    final keyCodeUnits = utf8.encode(key);
    final result = List<int>.generate(inputCodeUnits.length, (i) {
      return inputCodeUnits[i] ^ keyCodeUnits[i % keyCodeUnits.length];
    });
    return base64Encode(result);
  }

  String _xorDecipher(String base64Input, String key) {
    if (base64Input.isEmpty || key.isEmpty) return base64Input;
    try {
      final decodedBytes = base64Decode(base64Input);
      final keyCodeUnits = utf8.encode(key);
      final result = List<int>.generate(decodedBytes.length, (i) {
        return decodedBytes[i] ^ keyCodeUnits[i % keyCodeUnits.length];
      });
      return utf8.decode(result);
    } catch (_) {
      return '';
    }
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
