import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:janus/models/app_settings.dart';

/// Persistence layer for [AppSettings] using [shared_preferences].
///
/// Saves the settings as a JSON string under a single key,
/// so adding new fields is a no‑op for existing users.
class SettingsService {
  static const String _key = 'app_settings';
  static const String _apiKeySecKey = 'ai_api_key_secure';

  /// Obfuscates sensitive data using a lightweight XOR cipher before persistence.
  /// This prevents plain text credentials from being harvested via standard device backup
  /// or shared preference XML file scanning when robust keystores are not used.
  String _obscure(String text) {
    if (text.isEmpty) return '';
    final bytes = utf8.encode(text);
    final obscured = bytes.map((b) => b ^ 0x5A).toList();
    return base64.encode(obscured);
  }

  /// De-obfuscates the XOR-ciphered sensitive data retrieved from persistence.
  String _unobscure(String base64Text) {
    if (base64Text.isEmpty) return '';
    try {
      final bytes = base64.decode(base64Text);
      final unobscured = bytes.map((b) => b ^ 0x5A).toList();
      return utf8.decode(unobscured);
    } catch (_) {
      return '';
    }
  }

  /// Loads the obfuscated AI API key from shared preferences.
  Future<String> getAiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_apiKeySecKey) ?? '';
    return _unobscure(raw);
  }

  /// Obfuscates and persists the AI API key to shared preferences.
  Future<void> saveAiApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeySecKey, _obscure(apiKey));
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
