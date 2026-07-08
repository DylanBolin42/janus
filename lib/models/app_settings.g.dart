// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppSettingsImpl _$$AppSettingsImplFromJson(
  Map<String, dynamic> json,
) => _$AppSettingsImpl(
  themeMode:
      $enumDecodeNullable(_$AppThemeModeEnumMap, json['themeMode']) ??
      AppThemeMode.system,
  glassIntensity:
      $enumDecodeNullable(_$GlassIntensityEnumMap, json['glassIntensity']) ??
      GlassIntensity.moderate,
  language:
      $enumDecodeNullable(_$AppLanguageEnumMap, json['language']) ??
      AppLanguage.chinese,
  tabNamingStyle:
      $enumDecodeNullable(_$TabNamingStyleEnumMap, json['tabNamingStyle']) ??
      TabNamingStyle.classic,
  isNotificationEnabled: json['isNotificationEnabled'] as bool? ?? false,
  urgentNotificationStyle:
      $enumDecodeNullable(
        _$UrgentNotificationStyleEnumMap,
        json['urgentNotificationStyle'],
      ) ??
      UrgentNotificationStyle.notifier,
  approachingNotificationStyle:
      $enumDecodeNullable(
        _$ApproachingNotificationStyleEnumMap,
        json['approachingNotificationStyle'],
      ) ??
      ApproachingNotificationStyle.notifier,
  tempLeaveDuration:
      $enumDecodeNullable(
        _$TempLeaveDurationEnumMap,
        json['tempLeaveDuration'],
      ) ??
      TempLeaveDuration.tenM,
);

Map<String, dynamic> _$$AppSettingsImplToJson(
  _$AppSettingsImpl instance,
) => <String, dynamic>{
  'themeMode': _$AppThemeModeEnumMap[instance.themeMode]!,
  'glassIntensity': _$GlassIntensityEnumMap[instance.glassIntensity]!,
  'language': _$AppLanguageEnumMap[instance.language]!,
  'tabNamingStyle': _$TabNamingStyleEnumMap[instance.tabNamingStyle]!,
  'isNotificationEnabled': instance.isNotificationEnabled,
  'urgentNotificationStyle':
      _$UrgentNotificationStyleEnumMap[instance.urgentNotificationStyle]!,
  'approachingNotificationStyle':
      _$ApproachingNotificationStyleEnumMap[instance
          .approachingNotificationStyle]!,
  'tempLeaveDuration': _$TempLeaveDurationEnumMap[instance.tempLeaveDuration]!,
};

const _$AppThemeModeEnumMap = {
  AppThemeMode.system: 'system',
  AppThemeMode.light: 'light',
  AppThemeMode.dark: 'dark',
};

const _$GlassIntensityEnumMap = {
  GlassIntensity.extreme: 'extreme',
  GlassIntensity.moderate: 'moderate',
  GlassIntensity.low: 'low',
};

const _$AppLanguageEnumMap = {
  AppLanguage.chinese: 'zh',
  AppLanguage.english: 'en',
};

const _$TabNamingStyleEnumMap = {
  TabNamingStyle.classic: 'classic',
  TabNamingStyle.latin: 'latin',
  TabNamingStyle.professional: 'professional',
};

const _$UrgentNotificationStyleEnumMap = {
  UrgentNotificationStyle.notifier: 'notifier',
  UrgentNotificationStyle.notifierAndShake: 'notifierAndShake',
  UrgentNotificationStyle.notifierAndRing: 'notifierAndRing',
  UrgentNotificationStyle.fullScreenNotifier: 'FullScreenNotifier',
};

const _$ApproachingNotificationStyleEnumMap = {
  ApproachingNotificationStyle.notifier: 'notifier',
  ApproachingNotificationStyle.notifierAndShake: 'notifierAndShake',
  ApproachingNotificationStyle.notifierAndRing: 'notifierAndRing',
  ApproachingNotificationStyle.fullScreenNotifier: 'FullScreenNotifier',
};

const _$TempLeaveDurationEnumMap = {
  TempLeaveDuration.fiveM: '5min',
  TempLeaveDuration.tenM: '10min',
  TempLeaveDuration.fiftenM: '15min',
  TempLeaveDuration.twentyM: '20min',
};
