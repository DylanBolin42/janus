import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums — serializable to JSON via @JsonValue
// ─────────────────────────────────────────────────────────────────────────────

/// Theme mode enum that serializes cleanly to JSON.
///
/// Mirrors [ThemeMode] but with stable string values for persistence.
enum AppThemeMode {
  @JsonValue('system')
  system,
  @JsonValue('light')
  light,
  @JsonValue('dark')
  dark,
}

/// Extension to convert [AppThemeMode] to/from Flutter's [ThemeMode].
extension AppThemeModeX on AppThemeMode {
  ThemeMode toFlutter() {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  static AppThemeMode fromFlutter(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return AppThemeMode.system;
      case ThemeMode.light:
        return AppThemeMode.light;
      case ThemeMode.dark:
        return AppThemeMode.dark;
    }
  }
}

/// Glass rendering intensity levels.
///
/// Higher = more visual effect, more GPU work.
enum GlassIntensity {
  @JsonValue('extreme')
  extreme,
  @JsonValue('moderate')
  moderate,
  @JsonValue('low')
  low,
}

/// Available app languages.
enum AppLanguage {
  @JsonValue('zh')
  chinese,
  @JsonValue('en')
  english,
}

/// Tab naming style options.
enum TabNamingStyle {
  @JsonValue('classic')
  classic,
  @JsonValue('latin')
  latin,
  @JsonValue('professional')
  professional,
}

/// Display label for [AppThemeMode] in the settings UI.
extension AppThemeModeLabel on AppThemeMode {
  String get label {
    switch (this) {
      case AppThemeMode.system:
        return '跟随系统';
      case AppThemeMode.light:
        return '明亮模式';
      case AppThemeMode.dark:
        return '暗黑模式';
    }
  }
}

/// Display label for [GlassIntensity] in the settings UI.
extension GlassIntensityLabel on GlassIntensity {
  String get label {
    switch (this) {
      case GlassIntensity.extreme:
        return '极致';
      case GlassIntensity.moderate:
        return '适中';
      case GlassIntensity.low:
        return '低';
    }
  }
}

/// Display label for [AppLanguage] in the settings UI.
extension AppLanguageLabel on AppLanguage {
  String get label {
    switch (this) {
      case AppLanguage.chinese:
        return '中文';
      case AppLanguage.english:
        return 'English';
    }
  }
}

/// Display label for [TabNamingStyle] in the settings UI.
extension TabNamingStyleLabel on TabNamingStyle {
  String get label {
    switch (this) {
      case TabNamingStyle.classic:
        return '经典';
      case TabNamingStyle.latin:
        return '拉丁';
      case TabNamingStyle.professional:
        return '专业';
    }
  }
}

// 紧迫项的提醒方式
enum UrgentNotificationStyle {
  @JsonValue('notifier')
  notifier,
  @JsonValue('notifierAndShake')
  notifierAndShake,
  @JsonValue('notifierAndRing')
  notifierAndRing,
  @JsonValue('FullScreenNotifier')
  fullScreenNotifier,
}

// Display label for [UrgentNotificationStyle] in the settings UI.
extension UrgentNotificationStyleLabel on UrgentNotificationStyle {
  String get label {
    switch (this) {
      case UrgentNotificationStyle.notifier:
        return '仅通知';
      case UrgentNotificationStyle.notifierAndShake:
        return '通知+震动';
      case UrgentNotificationStyle.notifierAndRing:
        return '通知+响铃';
      case UrgentNotificationStyle.fullScreenNotifier:
        return '全屏通知';
    }
  }
}

// 迫近项的提醒方式
enum ApproachingNotificationStyle {
  @JsonValue('notifier')
  notifier,
  @JsonValue('notifierAndShake')
  notifierAndShake,
  @JsonValue('notifierAndRing')
  notifierAndRing,
  @JsonValue('FullScreenNotifier')
  fullScreenNotifier,
}

// Display label for [ApproachingNotificationStyle] in the settings UI.
extension ApproachingNotificationStyleLabel on ApproachingNotificationStyle {
  String get label {
    switch (this) {
      case ApproachingNotificationStyle.notifier:
        return '仅通知';
      case ApproachingNotificationStyle.notifierAndShake:
        return '通知+震动';
      case ApproachingNotificationStyle.notifierAndRing:
        return '通知+响铃';
      case ApproachingNotificationStyle.fullScreenNotifier:
        return '全屏通知';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Freezed model — AppSettings
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable settings model for the Janus app.
///
/// All fields have sensible defaults. Serializes to/from JSON
/// for persistence via [shared_preferences].
@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    // Gereral settings
    @Default(AppThemeMode.system) AppThemeMode themeMode,
    @Default(GlassIntensity.moderate) GlassIntensity glassIntensity,
    @Default(AppLanguage.chinese) AppLanguage language,
    @Default(TabNamingStyle.classic) TabNamingStyle tabNamingStyle,

    // Notification settings
    @Default(false) bool isNotificationEnabled,
    @Default(UrgentNotificationStyle.notifier)
    UrgentNotificationStyle urgentNotificationStyle,
    @Default(ApproachingNotificationStyle.notifier)
    ApproachingNotificationStyle approachingNotificationStyle,
  }) = _AppSettings;

  const AppSettings._();

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}
