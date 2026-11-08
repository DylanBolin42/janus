import 'package:flutter/material.dart';
import 'package:janus/models/app_settings.dart';
import 'package:janus/services/settings_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_provider.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Service provider
// ─────────────────────────────────────────────────────────────────────────────

/// Provides the singleton [SettingsService] instance.
@riverpod
SettingsService settingsService(Ref ref) {
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

  Future<void> _pending = Future.value();

  /// Serialize edits and apply each edit to the latest successfully saved value.
  /// In particular, an edit during startup must not replace stored settings
  /// with defaults, and simultaneous edits must not overwrite one another.
  Future<void> _persist(AppSettings Function(AppSettings) update) {
    final operation = _pending.then((_) async {
      final current = await future;
      final updated = update(current);
      await ref.read(settingsServiceProvider).save(updated);
      state = AsyncData(updated);
    });
    // A failed save is reported to its caller without poisoning subsequent edits.
    _pending = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  // ── Individual setters ───────────────────────────────────────────────

  Future<void> setThemeMode(AppThemeMode mode) async {
    await _persist((current) => current.copyWith(themeMode: mode));
  }

  Future<void> setGlassIntensity(GlassIntensity intensity) async {
    await _persist((current) => current.copyWith(glassIntensity: intensity));
  }

  Future<void> setLanguage(AppLanguage language) async {
    await _persist((current) => current.copyWith(language: language));
  }

  Future<void> setTabNamingStyle(TabNamingStyle style) async {
    await _persist((current) => current.copyWith(tabNamingStyle: style));
  }

  // ── Notification setters ─────────────────────────────────────────────

  Future<void> setNotificationEnabled(bool enabled) async {
    await _persist(
      (current) => current.copyWith(isNotificationEnabled: enabled),
    );
  }

  Future<void> setUrgentNotificationStyle(UrgentNotificationStyle style) async {
    await _persist(
      (current) => current.copyWith(urgentNotificationStyle: style),
    );
  }

  Future<void> setApproachingNotificationStyle(
    ApproachingNotificationStyle style,
  ) async {
    await _persist(
      (current) => current.copyWith(approachingNotificationStyle: style),
    );
  }

  Future<void> setMorningBriefingTime(TimeOfDay time) =>
      _persist((current) => current.copyWith(morningBriefingTime: time));

  Future<void> setEveningBriefingTime(TimeOfDay time) =>
      _persist((current) => current.copyWith(eveningBriefingTime: time));

  Future<void> setFocusTimerMode(FocusTimerMode mode) =>
      _persist((current) => current.copyWith(focusTimerMode: mode));

  // ── Focus settings ─────────────────────────────────────────────────

  Future<void> setTempLeaveDuration(TempLeaveDuration duration) async {
    await _persist((current) => current.copyWith(tempLeaveDuration: duration));
  }

  Future<void> setTempLeaveTimes(TempLeaveTimes times) async {
    await _persist((current) => current.copyWith(tempLeaveTimes: times));
  }

  Future<void> setFocusSceneRenderMode(FocusSceneRenderMode mode) async {
    await _persist((current) => current.copyWith(focusSceneRenderMode: mode));
  }

  Future<void> setFocusSceneRenderQuality(
    FocusSceneRenderQuality quality,
  ) async {
    await _persist(
      (current) => current.copyWith(focusSceneRenderQuality: quality),
    );
  }

  // Set Storage Settings
  Future<void> setUseLogToTrain(bool enabled) async {
    await _persist((current) => current.copyWith(useLogToTrain: enabled));
  }

  // Set Sync Settings
  Future<void> setSyncEnabled(bool enabled) async {
    await _persist((current) => current.copyWith(syncEnabled: enabled));
  }

  Future<void> setSyncMode(SyncMode mode) async {
    await _persist((current) => current.copyWith(syncMode: mode));
  }

  Future<void> setSyncTrigger(SyncTrigger trigger) async {
    await _persist((current) => current.copyWith(syncTrigger: trigger));
  }

  Future<void> setSyncDurationOnInterval(Duration duration) async {
    if (duration < const Duration(minutes: 1) ||
        duration >= const Duration(days: 1)) {
      throw ArgumentError.value(duration, 'duration', 'Must be 1–1439 minutes');
    }
    await _persist(
      (current) => current.copyWith(syncDurationOnInterval: duration),
    );
  }

  Future<void> setRsaType(RsaType type) async {
    await _persist((current) => current.copyWith(rsaType: type));
  }

  Future<void> setUseAppLock(bool enabled) async {
    await _persist((current) => current.copyWith(useAppLock: enabled));
  }

  // Planning settings
  Future<void> setWorkingDayTaskDensity(WorkingDayTaskDensity type) async {
    await _persist((current) => current.copyWith(workingDayTaskDensity: type));
  }

  Future<void> setRestDayTaskDensity(RestDayTaskDensity type) async {
    await _persist((current) => current.copyWith(restDayTaskDensity: type));
  }

  Future<void> setPlanningHorizon(PlanningHorizon horizon) async {
    await _persist((current) => current.copyWith(planningHorizon: horizon));
  }

  // AI settings
  Future<void> setUseAiDailySummary(bool enabled) async {
    await _persist((current) => current.copyWith(aiDailySummary: enabled));
  }

  Future<void> setAiAnalyseReport(bool enabled) async {
    await _persist((current) => current.copyWith(aiAnalyseReport: enabled));
  }

  Future<void> setAiTextToTask(bool enabled) async {
    await _persist((current) => current.copyWith(aiTextToTask: enabled));
  }

  Future<void> setAiPicToTask(bool enabled) async {
    await _persist((current) => current.copyWith(aiPicToTask: enabled));
  }

  // User Preference
  Future<void> setTaskCreationMode(TaskCreationMode mode) async {
    await _persist((current) => current.copyWith(taskCreationMode: mode));
  }
}
// ─────────────────────────────────────────────────────────────────────────────
// Theme-mode-only provider (convenience for MyApp)
// ─────────────────────────────────────────────────────────────────────────────

/// Exposes the resolved [ThemeMode] so [MaterialApp] can react to changes
/// without watching the full [AppSettings] in main.dart.
@riverpod
ThemeMode themeMode(Ref ref) {
  final settingsAsync = ref.watch(appSettingsProvider);
  return settingsAsync.value?.themeMode.toFlutter() ?? ThemeMode.system;
}
