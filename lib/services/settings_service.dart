import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:janus/models/app_settings.dart';

/// Persistence layer for [AppSettings] using [shared_preferences].
///
/// Saves the settings as a JSON string under a single key,
/// so adding new fields is a no‑op for existing users.
class SettingsService {
  static const String _key = 'app_settings';

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

  /// Validates whether an endpoint URL is secure and well-formed.
  ///
  /// Remote endpoints must enforce HTTPS to prevent MiTM attacks.
  /// Unencrypted HTTP is permitted only for local development on loopback hosts.
  static bool isValidEndpointUrl(String url) {
    if (url.trim().isEmpty) return true;
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return false;
    }
    if (uri.scheme == 'http') {
      final host = uri.host.toLowerCase();
      final isLoopback = host == 'localhost' || host == '127.0.0.1' || host == '::1';
      if (!isLoopback) return false;
    }
    return true;
  }
}
