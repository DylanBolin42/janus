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
  useLogToTrain: json['useLogToTrain'] as bool? ?? false,
  syncEnabled: json['syncEnabled'] as bool? ?? false,
  syncMode:
      $enumDecodeNullable(_$SyncModeEnumMap, json['syncMode']) ?? SyncMode.auto,
  syncTrigger:
      $enumDecodeNullable(_$SyncTriggerEnumMap, json['syncTrigger']) ??
      SyncTrigger.onTime,
  syncDurationOnInterval: json['syncDurationOnInterval'] == null
      ? const Duration(hours: 3)
      : Duration(microseconds: (json['syncDurationOnInterval'] as num).toInt()),
  rsaType:
      $enumDecodeNullable(_$RsaTypeEnumMap, json['rsaType']) ?? RsaType.rsa2048,
  useAppLock: json['useAppLock'] as bool? ?? false,
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
  'useLogToTrain': instance.useLogToTrain,
  'syncEnabled': instance.syncEnabled,
  'syncMode': _$SyncModeEnumMap[instance.syncMode]!,
  'syncTrigger': _$SyncTriggerEnumMap[instance.syncTrigger]!,
  'syncDurationOnInterval': instance.syncDurationOnInterval.inMicroseconds,
  'rsaType': _$RsaTypeEnumMap[instance.rsaType]!,
  'useAppLock': instance.useAppLock,
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
  TempLeaveTimes.once: 'once',
  TempLeaveTimes.twice: 'twice',
  TempLeaveTimes.threeTimes: 'threeTimes',
  TempLeaveTimes.fourTimes: 'fourTimes',
  TempLeaveTimes.fiveTimes: 'fiveTimes',
};

const _$FocusSceneRenderModeEnumMap = {
  FocusSceneRenderMode.unity: 'Unity',
  FocusSceneRenderMode.godot: 'Godot',
  FocusSceneRenderMode.rive: 'Rive',
};

const _$FocusSceneRenderQualityEnumMap = {
  FocusSceneRenderQuality.high: 'high',
  FocusSceneRenderQuality.medium: 'medium',
  FocusSceneRenderQuality.low: 'low',
};

const _$SyncModeEnumMap = {
  SyncMode.localFirst: 'LocalFirst',
  SyncMode.cloudFirst: 'CloudFirst',
  SyncMode.auto: 'Auto',
};

const _$SyncTriggerEnumMap = {
  SyncTrigger.onTime: 'OnTime',
  SyncTrigger.onInterval: 'OnInteral',
  SyncTrigger.onChanged: 'OnChanged',
};

const _$RsaTypeEnumMap = {
  RsaType.rsa2048: 'rsa-2048',
  RsaType.rsa3072: 'rsa-3072',
  RsaType.rsa4096: 'rsa-4096',
};
