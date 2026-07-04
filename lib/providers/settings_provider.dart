import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:janus/models/app_settings.dart';
import 'package:janus/services/settings_service.dart';

part 'settings_provider.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Service provider
// ─────────────────────────────────────────────────────────────────────────────

/// Provides the singleton [SettingsService] instance.
@riverpod
SettingsService settingsService(SettingsServiceRef ref) {
  return SettingsService();
}

// ─────────────────────────────────────────────────────────────────────────────
// Settings notifier
// ─────────────────────────────────────────────────────────────────────────────

/// Async notifier that loads, exposes, and persists [AppSettings].
///
/// Every mutation calls [_persist] which saves to [shared_preferences]
/// then updates [state] so all watchers rebuild.
@riverpod
class AppSettingsNotifier extends _$AppSettingsNotifier {
  @override
  Future<AppSettings> build() async {
    final service = ref.watch(settingsServiceProvider);
    return service.load();
  }

  /// Persist an updated settings object and update state.
  Future<void> _persist(AppSettings updated) async {
    final service = ref.read(settingsServiceProvider);
    await service.save(updated);
    state = AsyncData(updated);
  }

  // ── Individual setters ───────────────────────────────────────────────

  Future<void> setThemeMode(AppThemeMode mode) async {
    await _persist(
      (state.valueOrNull ?? const AppSettings()).copyWith(themeMode: mode),
    );
  }

  Future<void> setGlassIntensity(GlassIntensity intensity) async {
    await _persist(
      (state.valueOrNull ?? const AppSettings())
          .copyWith(glassIntensity: intensity),
    );
  }

  Future<void> setLanguage(AppLanguage language) async {
    await _persist(
      (state.valueOrNull ?? const AppSettings()).copyWith(language: language),
    );
  }

  Future<void> setTabNamingStyle(TabNamingStyle style) async {
    await _persist(
      (state.valueOrNull ?? const AppSettings())
          .copyWith(tabNamingStyle: style),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme-mode-only provider (convenience for MyApp)
// ─────────────────────────────────────────────────────────────────────────────

/// Exposes the resolved [ThemeMode] so [MaterialApp] can react to changes
/// without watching the full [AppSettings] in main.dart.
@riverpod
ThemeMode themeMode(ThemeModeRef ref) {
  final settingsAsync = ref.watch(appSettingsNotifierProvider);
  return settingsAsync.valueOrNull?.themeMode.toFlutter() ?? ThemeMode.system;
}
