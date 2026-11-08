import 'dart:convert';
import 'package:flutter/services.dart';
import 'sync_backend.dart';

/// Platform Keychain / Android Keystore bridge. Never falls back to preferences.
class SyncCredentials {
  static const channel = MethodChannel('janus/sync_credentials');
  Future<SyncConfig?> load() async {
    final raw = await channel.invokeMethod<String>('read');
    return raw == null
        ? null
        : SyncConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(SyncConfig config) async {
    config.directory;
    await channel.invokeMethod<void>('write', jsonEncode(config.toJson()));
  }
}
