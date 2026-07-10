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
  tempLeaveTimes:
      $enumDecodeNullable(_$TempLeaveTimesEnumMap, json['tempLeaveTimes']) ??
      TempLeaveTimes.twice,
  focusSceneRenderMode:
      $enumDecodeNullable(
        _$FocusSceneRenderModeEnumMap,
        json['focusSceneRenderMode'],
      ) ??
      FocusSceneRenderMode.rive,
  focusSceneRenderQuality:
      $enumDecodeNullable(
        _$FocusSceneRenderQualityEnumMap,
        json['focusSceneRenderQuality'],
      ) ??
      FocusSceneRenderQuality.medium,
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
  'tempLeaveTimes': _$TempLeaveTimesEnumMap[instance.tempLeaveTimes]!,
  'focusSceneRenderMode':
      _$FocusSceneRenderModeEnumMap[instance.focusSceneRenderMode]!,
  'focusSceneRenderQuality':
      _$FocusSceneRenderQualityEnumMap[instance.focusSceneRenderQuality]!,
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

const _$TempLeaveTimesEnumMap = {
  TempLeaveTimes.once: '1次',
  TempLeaveTimes.twice: '2次',
  TempLeaveTimes.threeTimes: '3次',
  TempLeaveTimes.fourTimes: '4次',
  TempLeaveTimes.fiveTimes: '5次',
};

const _$FocusSceneRenderModeEnumMap = {
  FocusSceneRenderMode.unity: 'Unity',
  FocusSceneRenderMode.godot: 'Godot',
  FocusSceneRenderMode.rive: 'Rive',
};

const _$FocusSceneRenderQualityEnumMap = {
  FocusSceneRenderQuality.high: '高',
  FocusSceneRenderQuality.medium: '中',
  FocusSceneRenderQuality.low: '低',
};
