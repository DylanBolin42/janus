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
      (state.valueOrNull ?? const AppSettings()).copyWith(
        glassIntensity: intensity,
      ),
    );
  }

  Future<void> setLanguage(AppLanguage language) async {
    await _persist(
      (state.valueOrNull ?? const AppSettings()).copyWith(language: language),
    );
  }

  Future<void> setTabNamingStyle(TabNamingStyle style) async {
    await _persist(
      (state.valueOrNull ?? const AppSettings()).copyWith(
        tabNamingStyle: style,
      ),
    );
  }

  // ── Notification setters ─────────────────────────────────────────────

  Future<void> setNotificationEnabled(bool enabled) async {
    await _persist(
      (state.valueOrNull ?? const AppSettings()).copyWith(
        isNotificationEnabled: enabled,
      ),
    );
  }

  Future<void> setUrgentNotificationStyle(UrgentNotificationStyle style) async {
    await _persist(
      (state.valueOrNull ?? const AppSettings()).copyWith(
        urgentNotificationStyle: style,
      ),
    );
  }

  Future<void> setApproachingNotificationStyle(
    ApproachingNotificationStyle style,
  ) async {
    await _persist(
      (state.valueOrNull ?? const AppSettings()).copyWith(
        approachingNotificationStyle: style,
      ),
    );
  }

  // Set Focus Settings
  Future<void> setTempLeaveDuration(TempLeaveDuration duration) async {
    await _persist(
      (state.valueOrNull ?? const AppSettings()).copyWith(
        tempLeaveDuration: duration,
      ),
    );
  }

  Future<void> setTempLeaveTimes(TempLeaveTimes times) async {
    await _persist(
      (state.valueOrNull ?? const AppSettings()).copyWith(
        tempLeaveTimes: times,
      ),
    );
  }

  Future<void> setFocusSceneRenderMode(FocusSceneRenderMode mode) async {
    await _persist(
      (state.valueOrNull ?? const AppSettings()).copyWith(
        focusSceneRenderMode: mode,
      ),
    );
  }

  Future<void> setFocusSceneRenderQuality(
    FocusSceneRenderQuality quality,
  ) async {
    await _persist(
      (state.valueOrNull ?? const AppSettings()).copyWith(
        focusSceneRenderQuality: quality,
      ),
    );
  }

  // Set Storage Settings
  Future<void> setUseLogToTrain(bool enabled) async {
    await _persist(
      (state.valueOrNull ?? const AppSettings()).copyWith(
        useLogToTrain: enabled,
      ),
    );
  }

  // Set Sync Settings
  Future<void> setSyncEnabled(bool enabled) async {
    await _persist(
      (state.valueOrNull ?? const AppSettings()).copyWith(syncEnabled: enabled),
    );
  }

  Future<void> setSyncMode(SyncMode mode) async {
    await _persist(
      (state.valueOrNull ?? const AppSettings()).copyWith(syncMode: mode),
    );
  }

  Future<void> setSyncTrigger(SyncTrigger trigger) async {
    await _persist(
      (state.valueOrNull ?? const AppSettings()).copyWith(syncTrigger: trigger),
    );
  }

  Future<void> setSyncDurationOnInterval(Duration duration) async {
    await _persist(
      (state.valueOrNull ?? const AppSettings()).copyWith(
        syncDurationOnInterval: duration,
      ),
    );
  }

  Future<void> setRsaType(RsaType type) async {
    await _persist(
      (state.valueOrNull ?? const AppSettings()).copyWith(rsaType: type),
    );
  }

  Future<void> setUseAppLock(bool enabled) async {
    await _persist(
      (state.valueOrNull ?? const AppSettings()).copyWith(useAppLock: enabled),
    );
  }

  // Planning settings
  Future<void> setWorkingDayTaskDensity(WorkingDayTaskDensity type) async {
    await _persist(
      (state.valueOrNull ?? const AppSettings()).copyWith(
        workingDayTaskDensity: type,
      ),
    );
  }

  Future<void> setRestDayTaskDensity(RestDayTaskDensity type) async {
    await _persist(
      (state.valueOrNull ?? const AppSettings()).copyWith(
        restDayTaskDensity: type,
      ),
    );
  }

  Future<void> setPlanningHorizon(PlanningHorizon horizon) async {
    await _persist(
      (state.valueOrNull ?? const AppSettings()).copyWith(
        planningHorizon: horizon,
      ),
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
