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

/// Display label and icon for [AppThemeMode] in the settings UI.
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

  IconData get icon {
    switch (this) {
      case AppThemeMode.system:
        return Icons.brightness_auto_rounded;
      case AppThemeMode.light:
        return Icons.light_mode_rounded;
      case AppThemeMode.dark:
        return Icons.dark_mode_rounded;
    }
  }
}

/// Display label and icon for [GlassIntensity] in the settings UI.
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

  IconData get icon {
    switch (this) {
      case GlassIntensity.extreme:
        return Icons.auto_awesome_rounded;
      case GlassIntensity.moderate:
        return Icons.water_drop_rounded;
      case GlassIntensity.low:
        return Icons.blur_on_rounded;
    }
  }
}

/// Display label and icon for [AppLanguage] in the settings UI.
extension AppLanguageLabel on AppLanguage {
  String get label {
    switch (this) {
      case AppLanguage.chinese:
        return '中文';
      case AppLanguage.english:
        return 'English';
    }
  }

  IconData get icon {
    switch (this) {
      case AppLanguage.chinese:
        return Icons.translate_rounded;
      case AppLanguage.english:
        return Icons.language_rounded;
    }
  }
}

/// Display label and icon for [TabNamingStyle] in the settings UI.
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

  IconData get icon {
    switch (this) {
      case TabNamingStyle.classic:
        return Icons.style_rounded;
      case TabNamingStyle.latin:
        return Icons.text_fields_rounded;
      case TabNamingStyle.professional:
        return Icons.work_rounded;
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

// Display label and icon for [UrgentNotificationStyle] in the settings UI.
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

  IconData get icon {
    switch (this) {
      case UrgentNotificationStyle.notifier:
        return Icons.notifications_rounded;
      case UrgentNotificationStyle.notifierAndShake:
        return Icons.vibration_rounded;
      case UrgentNotificationStyle.notifierAndRing:
        return Icons.notifications_active_rounded;
      case UrgentNotificationStyle.fullScreenNotifier:
        return Icons.fullscreen_rounded;
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

// Display label and icon for [ApproachingNotificationStyle] in the settings UI.
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

  IconData get icon {
    switch (this) {
      case ApproachingNotificationStyle.notifier:
        return Icons.notifications_rounded;
      case ApproachingNotificationStyle.notifierAndShake:
        return Icons.vibration_rounded;
      case ApproachingNotificationStyle.notifierAndRing:
        return Icons.notifications_active_rounded;
      case ApproachingNotificationStyle.fullScreenNotifier:
        return Icons.fullscreen_rounded;
    }
  }
}

// 暂离时间标识
enum TempLeaveDuration {
  @JsonValue('5min')
  fiveM,
  @JsonValue('10min')
  tenM,
  @JsonValue('15min')
  fiftenM,
  @JsonValue('20min')
  twentyM,
}

extension TempLeaveDurationLabel on TempLeaveDuration {
  String get label {
    switch (this) {
      case TempLeaveDuration.fiftenM:
        return '15分钟';
      case TempLeaveDuration.fiveM:
        return '5分钟';
      case TempLeaveDuration.tenM:
        return '10分钟';
      case TempLeaveDuration.twentyM:
        return '20分钟';
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

    // Focus settings
    @Default(TempLeaveDuration.tenM) TempLeaveDuration tempLeaveDuration,
  }) = _AppSettings;

  const AppSettings._();

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}
