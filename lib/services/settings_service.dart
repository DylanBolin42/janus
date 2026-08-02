import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:janus/models/app_settings.dart';

/// Persistence layer for [AppSettings] using [shared_preferences].
///
/// Saves the settings as a JSON string under a single key,
/// so adding new fields is a no‑op for existing users.
class SettingsService {
  static const String _key = 'app_settings';
  static const String _apiKeyKey = 'secure_api_key';
  static const int _xorKey =
      0x5A; // Lightweight XOR key for obfuscating API key on disk

  SharedPreferences? _prefs;

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

  /// XOR obfuscates/deobfuscates a string.
  String _xorObfuscate(String input) {
    if (input.isEmpty) return '';
    final bytes = utf8.encode(input);
    final obfuscated = bytes.map((b) => b ^ _xorKey).toList();
    return base64.encode(obfuscated);
  }

  String _xorDeobfuscate(String input) {
    if (input.isEmpty) return '';
    try {
      final decoded = base64.decode(input);
      final deobfuscated = decoded.map((b) => b ^ _xorKey).toList();
      return utf8.decode(deobfuscated);
    } catch (_) {
      return '';
    }
  }

  /// Loads the obfuscated API key from shared preferences.
  Future<String> loadApiKey() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_apiKeyKey);
    if (raw == null) return '';
    return _xorDeobfuscate(raw);
  }

  /// Persists the API key obfuscated to shared preferences.
  Future<void> saveApiKey(String apiKey) async {
    final prefs = await _getPrefs();
    final obfuscated = _xorObfuscate(apiKey);
    await prefs.setString(_apiKeyKey, obfuscated);
  }
}
