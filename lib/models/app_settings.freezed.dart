// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppSettings {

 AppThemeMode get themeMode; GlassIntensity get glassIntensity; AppLanguage get language; TabNamingStyle get tabNamingStyle; bool get isNotificationEnabled; UrgentNotificationStyle get urgentNotificationStyle; ApproachingNotificationStyle get approachingNotificationStyle; TempLeaveDuration get tempLeaveDuration; TempLeaveTimes get tempLeaveTimes; FocusSceneRenderMode get focusSceneRenderMode; FocusSceneRenderQuality get focusSceneRenderQuality; bool get useLogToTrain; bool get syncEnabled; SyncMode get syncMode; SyncTrigger get syncTrigger; Duration get syncDurationOnInterval; RsaType get rsaType; bool get useAppLock;@TimeOfDayConverter() TimeOfDay get workHourStart; WorkingDayTaskDensity get workingDayTaskDensity; RestDayTaskDensity get restDayTaskDensity; PlanningHorizon get planningHorizon; String get endPoint; String get modelName; bool get aiDailySummary; bool get aiAnalyseReport; bool get aiTextToTask; bool get aiPicToTask;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.glassIntensity, glassIntensity) || other.glassIntensity == glassIntensity)&&(identical(other.language, language) || other.language == language)&&(identical(other.tabNamingStyle, tabNamingStyle) || other.tabNamingStyle == tabNamingStyle)&&(identical(other.isNotificationEnabled, isNotificationEnabled) || other.isNotificationEnabled == isNotificationEnabled)&&(identical(other.urgentNotificationStyle, urgentNotificationStyle) || other.urgentNotificationStyle == urgentNotificationStyle)&&(identical(other.approachingNotificationStyle, approachingNotificationStyle) || other.approachingNotificationStyle == approachingNotificationStyle)&&(identical(other.tempLeaveDuration, tempLeaveDuration) || other.tempLeaveDuration == tempLeaveDuration)&&(identical(other.tempLeaveTimes, tempLeaveTimes) || other.tempLeaveTimes == tempLeaveTimes)&&(identical(other.focusSceneRenderMode, focusSceneRenderMode) || other.focusSceneRenderMode == focusSceneRenderMode)&&(identical(other.focusSceneRenderQuality, focusSceneRenderQuality) || other.focusSceneRenderQuality == focusSceneRenderQuality)&&(identical(other.useLogToTrain, useLogToTrain) || other.useLogToTrain == useLogToTrain)&&(identical(other.syncEnabled, syncEnabled) || other.syncEnabled == syncEnabled)&&(identical(other.syncMode, syncMode) || other.syncMode == syncMode)&&(identical(other.syncTrigger, syncTrigger) || other.syncTrigger == syncTrigger)&&(identical(other.syncDurationOnInterval, syncDurationOnInterval) || other.syncDurationOnInterval == syncDurationOnInterval)&&(identical(other.rsaType, rsaType) || other.rsaType == rsaType)&&(identical(other.useAppLock, useAppLock) || other.useAppLock == useAppLock)&&(identical(other.workHourStart, workHourStart) || other.workHourStart == workHourStart)&&(identical(other.workingDayTaskDensity, workingDayTaskDensity) || other.workingDayTaskDensity == workingDayTaskDensity)&&(identical(other.restDayTaskDensity, restDayTaskDensity) || other.restDayTaskDensity == restDayTaskDensity)&&(identical(other.planningHorizon, planningHorizon) || other.planningHorizon == planningHorizon)&&(identical(other.endPoint, endPoint) || other.endPoint == endPoint)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.aiDailySummary, aiDailySummary) || other.aiDailySummary == aiDailySummary)&&(identical(other.aiAnalyseReport, aiAnalyseReport) || other.aiAnalyseReport == aiAnalyseReport)&&(identical(other.aiTextToTask, aiTextToTask) || other.aiTextToTask == aiTextToTask)&&(identical(other.aiPicToTask, aiPicToTask) || other.aiPicToTask == aiPicToTask));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,themeMode,glassIntensity,language,tabNamingStyle,isNotificationEnabled,urgentNotificationStyle,approachingNotificationStyle,tempLeaveDuration,tempLeaveTimes,focusSceneRenderMode,focusSceneRenderQuality,useLogToTrain,syncEnabled,syncMode,syncTrigger,syncDurationOnInterval,rsaType,useAppLock,workHourStart,workingDayTaskDensity,restDayTaskDensity,planningHorizon,endPoint,modelName,aiDailySummary,aiAnalyseReport,aiTextToTask,aiPicToTask]);

@override
String toString() {
  return 'AppSettings(themeMode: $themeMode, glassIntensity: $glassIntensity, language: $language, tabNamingStyle: $tabNamingStyle, isNotificationEnabled: $isNotificationEnabled, urgentNotificationStyle: $urgentNotificationStyle, approachingNotificationStyle: $approachingNotificationStyle, tempLeaveDuration: $tempLeaveDuration, tempLeaveTimes: $tempLeaveTimes, focusSceneRenderMode: $focusSceneRenderMode, focusSceneRenderQuality: $focusSceneRenderQuality, useLogToTrain: $useLogToTrain, syncEnabled: $syncEnabled, syncMode: $syncMode, syncTrigger: $syncTrigger, syncDurationOnInterval: $syncDurationOnInterval, rsaType: $rsaType, useAppLock: $useAppLock, workHourStart: $workHourStart, workingDayTaskDensity: $workingDayTaskDensity, restDayTaskDensity: $restDayTaskDensity, planningHorizon: $planningHorizon, endPoint: $endPoint, modelName: $modelName, aiDailySummary: $aiDailySummary, aiAnalyseReport: $aiAnalyseReport, aiTextToTask: $aiTextToTask, aiPicToTask: $aiPicToTask)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 AppThemeMode themeMode, GlassIntensity glassIntensity, AppLanguage language, TabNamingStyle tabNamingStyle, bool isNotificationEnabled, UrgentNotificationStyle urgentNotificationStyle, ApproachingNotificationStyle approachingNotificationStyle, TempLeaveDuration tempLeaveDuration, TempLeaveTimes tempLeaveTimes, FocusSceneRenderMode focusSceneRenderMode, FocusSceneRenderQuality focusSceneRenderQuality, bool useLogToTrain, bool syncEnabled, SyncMode syncMode, SyncTrigger syncTrigger, Duration syncDurationOnInterval, RsaType rsaType, bool useAppLock,@TimeOfDayConverter() TimeOfDay workHourStart, WorkingDayTaskDensity workingDayTaskDensity, RestDayTaskDensity restDayTaskDensity, PlanningHorizon planningHorizon, String endPoint, String modelName, bool aiDailySummary, bool aiAnalyseReport, bool aiTextToTask, bool aiPicToTask
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? themeMode = null,Object? glassIntensity = null,Object? language = null,Object? tabNamingStyle = null,Object? isNotificationEnabled = null,Object? urgentNotificationStyle = null,Object? approachingNotificationStyle = null,Object? tempLeaveDuration = null,Object? tempLeaveTimes = null,Object? focusSceneRenderMode = null,Object? focusSceneRenderQuality = null,Object? useLogToTrain = null,Object? syncEnabled = null,Object? syncMode = null,Object? syncTrigger = null,Object? syncDurationOnInterval = null,Object? rsaType = null,Object? useAppLock = null,Object? workHourStart = null,Object? workingDayTaskDensity = null,Object? restDayTaskDensity = null,Object? planningHorizon = null,Object? endPoint = null,Object? modelName = null,Object? aiDailySummary = null,Object? aiAnalyseReport = null,Object? aiTextToTask = null,Object? aiPicToTask = null,}) {
  return _then(_self.copyWith(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as AppThemeMode,glassIntensity: null == glassIntensity ? _self.glassIntensity : glassIntensity // ignore: cast_nullable_to_non_nullable
as GlassIntensity,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as AppLanguage,tabNamingStyle: null == tabNamingStyle ? _self.tabNamingStyle : tabNamingStyle // ignore: cast_nullable_to_non_nullable
as TabNamingStyle,isNotificationEnabled: null == isNotificationEnabled ? _self.isNotificationEnabled : isNotificationEnabled // ignore: cast_nullable_to_non_nullable
as bool,urgentNotificationStyle: null == urgentNotificationStyle ? _self.urgentNotificationStyle : urgentNotificationStyle // ignore: cast_nullable_to_non_nullable
as UrgentNotificationStyle,approachingNotificationStyle: null == approachingNotificationStyle ? _self.approachingNotificationStyle : approachingNotificationStyle // ignore: cast_nullable_to_non_nullable
as ApproachingNotificationStyle,tempLeaveDuration: null == tempLeaveDuration ? _self.tempLeaveDuration : tempLeaveDuration // ignore: cast_nullable_to_non_nullable
as TempLeaveDuration,tempLeaveTimes: null == tempLeaveTimes ? _self.tempLeaveTimes : tempLeaveTimes // ignore: cast_nullable_to_non_nullable
as TempLeaveTimes,focusSceneRenderMode: null == focusSceneRenderMode ? _self.focusSceneRenderMode : focusSceneRenderMode // ignore: cast_nullable_to_non_nullable
as FocusSceneRenderMode,focusSceneRenderQuality: null == focusSceneRenderQuality ? _self.focusSceneRenderQuality : focusSceneRenderQuality // ignore: cast_nullable_to_non_nullable
as FocusSceneRenderQuality,useLogToTrain: null == useLogToTrain ? _self.useLogToTrain : useLogToTrain // ignore: cast_nullable_to_non_nullable
as bool,syncEnabled: null == syncEnabled ? _self.syncEnabled : syncEnabled // ignore: cast_nullable_to_non_nullable
as bool,syncMode: null == syncMode ? _self.syncMode : syncMode // ignore: cast_nullable_to_non_nullable
as SyncMode,syncTrigger: null == syncTrigger ? _self.syncTrigger : syncTrigger // ignore: cast_nullable_to_non_nullable
as SyncTrigger,syncDurationOnInterval: null == syncDurationOnInterval ? _self.syncDurationOnInterval : syncDurationOnInterval // ignore: cast_nullable_to_non_nullable
as Duration,rsaType: null == rsaType ? _self.rsaType : rsaType // ignore: cast_nullable_to_non_nullable
as RsaType,useAppLock: null == useAppLock ? _self.useAppLock : useAppLock // ignore: cast_nullable_to_non_nullable
as bool,workHourStart: null == workHourStart ? _self.workHourStart : workHourStart // ignore: cast_nullable_to_non_nullable
as TimeOfDay,workingDayTaskDensity: null == workingDayTaskDensity ? _self.workingDayTaskDensity : workingDayTaskDensity // ignore: cast_nullable_to_non_nullable
as WorkingDayTaskDensity,restDayTaskDensity: null == restDayTaskDensity ? _self.restDayTaskDensity : restDayTaskDensity // ignore: cast_nullable_to_non_nullable
as RestDayTaskDensity,planningHorizon: null == planningHorizon ? _self.planningHorizon : planningHorizon // ignore: cast_nullable_to_non_nullable
as PlanningHorizon,endPoint: null == endPoint ? _self.endPoint : endPoint // ignore: cast_nullable_to_non_nullable
as String,modelName: null == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String,aiDailySummary: null == aiDailySummary ? _self.aiDailySummary : aiDailySummary // ignore: cast_nullable_to_non_nullable
as bool,aiAnalyseReport: null == aiAnalyseReport ? _self.aiAnalyseReport : aiAnalyseReport // ignore: cast_nullable_to_non_nullable
as bool,aiTextToTask: null == aiTextToTask ? _self.aiTextToTask : aiTextToTask // ignore: cast_nullable_to_non_nullable
as bool,aiPicToTask: null == aiPicToTask ? _self.aiPicToTask : aiPicToTask // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AppThemeMode themeMode,  GlassIntensity glassIntensity,  AppLanguage language,  TabNamingStyle tabNamingStyle,  bool isNotificationEnabled,  UrgentNotificationStyle urgentNotificationStyle,  ApproachingNotificationStyle approachingNotificationStyle,  TempLeaveDuration tempLeaveDuration,  TempLeaveTimes tempLeaveTimes,  FocusSceneRenderMode focusSceneRenderMode,  FocusSceneRenderQuality focusSceneRenderQuality,  bool useLogToTrain,  bool syncEnabled,  SyncMode syncMode,  SyncTrigger syncTrigger,  Duration syncDurationOnInterval,  RsaType rsaType,  bool useAppLock, @TimeOfDayConverter()  TimeOfDay workHourStart,  WorkingDayTaskDensity workingDayTaskDensity,  RestDayTaskDensity restDayTaskDensity,  PlanningHorizon planningHorizon,  String endPoint,  String modelName,  bool aiDailySummary,  bool aiAnalyseReport,  bool aiTextToTask,  bool aiPicToTask)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.themeMode,_that.glassIntensity,_that.language,_that.tabNamingStyle,_that.isNotificationEnabled,_that.urgentNotificationStyle,_that.approachingNotificationStyle,_that.tempLeaveDuration,_that.tempLeaveTimes,_that.focusSceneRenderMode,_that.focusSceneRenderQuality,_that.useLogToTrain,_that.syncEnabled,_that.syncMode,_that.syncTrigger,_that.syncDurationOnInterval,_that.rsaType,_that.useAppLock,_that.workHourStart,_that.workingDayTaskDensity,_that.restDayTaskDensity,_that.planningHorizon,_that.endPoint,_that.modelName,_that.aiDailySummary,_that.aiAnalyseReport,_that.aiTextToTask,_that.aiPicToTask);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AppThemeMode themeMode,  GlassIntensity glassIntensity,  AppLanguage language,  TabNamingStyle tabNamingStyle,  bool isNotificationEnabled,  UrgentNotificationStyle urgentNotificationStyle,  ApproachingNotificationStyle approachingNotificationStyle,  TempLeaveDuration tempLeaveDuration,  TempLeaveTimes tempLeaveTimes,  FocusSceneRenderMode focusSceneRenderMode,  FocusSceneRenderQuality focusSceneRenderQuality,  bool useLogToTrain,  bool syncEnabled,  SyncMode syncMode,  SyncTrigger syncTrigger,  Duration syncDurationOnInterval,  RsaType rsaType,  bool useAppLock, @TimeOfDayConverter()  TimeOfDay workHourStart,  WorkingDayTaskDensity workingDayTaskDensity,  RestDayTaskDensity restDayTaskDensity,  PlanningHorizon planningHorizon,  String endPoint,  String modelName,  bool aiDailySummary,  bool aiAnalyseReport,  bool aiTextToTask,  bool aiPicToTask)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.themeMode,_that.glassIntensity,_that.language,_that.tabNamingStyle,_that.isNotificationEnabled,_that.urgentNotificationStyle,_that.approachingNotificationStyle,_that.tempLeaveDuration,_that.tempLeaveTimes,_that.focusSceneRenderMode,_that.focusSceneRenderQuality,_that.useLogToTrain,_that.syncEnabled,_that.syncMode,_that.syncTrigger,_that.syncDurationOnInterval,_that.rsaType,_that.useAppLock,_that.workHourStart,_that.workingDayTaskDensity,_that.restDayTaskDensity,_that.planningHorizon,_that.endPoint,_that.modelName,_that.aiDailySummary,_that.aiAnalyseReport,_that.aiTextToTask,_that.aiPicToTask);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AppThemeMode themeMode,  GlassIntensity glassIntensity,  AppLanguage language,  TabNamingStyle tabNamingStyle,  bool isNotificationEnabled,  UrgentNotificationStyle urgentNotificationStyle,  ApproachingNotificationStyle approachingNotificationStyle,  TempLeaveDuration tempLeaveDuration,  TempLeaveTimes tempLeaveTimes,  FocusSceneRenderMode focusSceneRenderMode,  FocusSceneRenderQuality focusSceneRenderQuality,  bool useLogToTrain,  bool syncEnabled,  SyncMode syncMode,  SyncTrigger syncTrigger,  Duration syncDurationOnInterval,  RsaType rsaType,  bool useAppLock, @TimeOfDayConverter()  TimeOfDay workHourStart,  WorkingDayTaskDensity workingDayTaskDensity,  RestDayTaskDensity restDayTaskDensity,  PlanningHorizon planningHorizon,  String endPoint,  String modelName,  bool aiDailySummary,  bool aiAnalyseReport,  bool aiTextToTask,  bool aiPicToTask)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.themeMode,_that.glassIntensity,_that.language,_that.tabNamingStyle,_that.isNotificationEnabled,_that.urgentNotificationStyle,_that.approachingNotificationStyle,_that.tempLeaveDuration,_that.tempLeaveTimes,_that.focusSceneRenderMode,_that.focusSceneRenderQuality,_that.useLogToTrain,_that.syncEnabled,_that.syncMode,_that.syncTrigger,_that.syncDurationOnInterval,_that.rsaType,_that.useAppLock,_that.workHourStart,_that.workingDayTaskDensity,_that.restDayTaskDensity,_that.planningHorizon,_that.endPoint,_that.modelName,_that.aiDailySummary,_that.aiAnalyseReport,_that.aiTextToTask,_that.aiPicToTask);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppSettings extends AppSettings {
  const _AppSettings({this.themeMode = AppThemeMode.system, this.glassIntensity = GlassIntensity.moderate, this.language = AppLanguage.chinese, this.tabNamingStyle = TabNamingStyle.classic, this.isNotificationEnabled = false, this.urgentNotificationStyle = UrgentNotificationStyle.notifier, this.approachingNotificationStyle = ApproachingNotificationStyle.notifier, this.tempLeaveDuration = TempLeaveDuration.tenM, this.tempLeaveTimes = TempLeaveTimes.twice, this.focusSceneRenderMode = FocusSceneRenderMode.rive, this.focusSceneRenderQuality = FocusSceneRenderQuality.medium, this.useLogToTrain = false, this.syncEnabled = false, this.syncMode = SyncMode.auto, this.syncTrigger = SyncTrigger.onTime, this.syncDurationOnInterval = const Duration(hours: 3), this.rsaType = RsaType.rsa2048, this.useAppLock = false, @TimeOfDayConverter() this.workHourStart = const TimeOfDay(hour: 8, minute: 0), this.workingDayTaskDensity = WorkingDayTaskDensity.medium, this.restDayTaskDensity = RestDayTaskDensity.loose, this.planningHorizon = PlanningHorizon.weeks, this.endPoint = '', this.modelName = '', this.aiDailySummary = false, this.aiAnalyseReport = false, this.aiTextToTask = false, this.aiPicToTask = false}): super._();
  factory _AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);

@override@JsonKey() final  AppThemeMode themeMode;
@override@JsonKey() final  GlassIntensity glassIntensity;
@override@JsonKey() final  AppLanguage language;
@override@JsonKey() final  TabNamingStyle tabNamingStyle;
@override@JsonKey() final  bool isNotificationEnabled;
@override@JsonKey() final  UrgentNotificationStyle urgentNotificationStyle;
@override@JsonKey() final  ApproachingNotificationStyle approachingNotificationStyle;
@override@JsonKey() final  TempLeaveDuration tempLeaveDuration;
@override@JsonKey() final  TempLeaveTimes tempLeaveTimes;
@override@JsonKey() final  FocusSceneRenderMode focusSceneRenderMode;
@override@JsonKey() final  FocusSceneRenderQuality focusSceneRenderQuality;
@override@JsonKey() final  bool useLogToTrain;
@override@JsonKey() final  bool syncEnabled;
@override@JsonKey() final  SyncMode syncMode;
@override@JsonKey() final  SyncTrigger syncTrigger;
@override@JsonKey() final  Duration syncDurationOnInterval;
@override@JsonKey() final  RsaType rsaType;
@override@JsonKey() final  bool useAppLock;
@override@JsonKey()@TimeOfDayConverter() final  TimeOfDay workHourStart;
@override@JsonKey() final  WorkingDayTaskDensity workingDayTaskDensity;
@override@JsonKey() final  RestDayTaskDensity restDayTaskDensity;
@override@JsonKey() final  PlanningHorizon planningHorizon;
@override@JsonKey() final  String endPoint;
@override@JsonKey() final  String modelName;
@override@JsonKey() final  bool aiDailySummary;
@override@JsonKey() final  bool aiAnalyseReport;
@override@JsonKey() final  bool aiTextToTask;
@override@JsonKey() final  bool aiPicToTask;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.glassIntensity, glassIntensity) || other.glassIntensity == glassIntensity)&&(identical(other.language, language) || other.language == language)&&(identical(other.tabNamingStyle, tabNamingStyle) || other.tabNamingStyle == tabNamingStyle)&&(identical(other.isNotificationEnabled, isNotificationEnabled) || other.isNotificationEnabled == isNotificationEnabled)&&(identical(other.urgentNotificationStyle, urgentNotificationStyle) || other.urgentNotificationStyle == urgentNotificationStyle)&&(identical(other.approachingNotificationStyle, approachingNotificationStyle) || other.approachingNotificationStyle == approachingNotificationStyle)&&(identical(other.tempLeaveDuration, tempLeaveDuration) || other.tempLeaveDuration == tempLeaveDuration)&&(identical(other.tempLeaveTimes, tempLeaveTimes) || other.tempLeaveTimes == tempLeaveTimes)&&(identical(other.focusSceneRenderMode, focusSceneRenderMode) || other.focusSceneRenderMode == focusSceneRenderMode)&&(identical(other.focusSceneRenderQuality, focusSceneRenderQuality) || other.focusSceneRenderQuality == focusSceneRenderQuality)&&(identical(other.useLogToTrain, useLogToTrain) || other.useLogToTrain == useLogToTrain)&&(identical(other.syncEnabled, syncEnabled) || other.syncEnabled == syncEnabled)&&(identical(other.syncMode, syncMode) || other.syncMode == syncMode)&&(identical(other.syncTrigger, syncTrigger) || other.syncTrigger == syncTrigger)&&(identical(other.syncDurationOnInterval, syncDurationOnInterval) || other.syncDurationOnInterval == syncDurationOnInterval)&&(identical(other.rsaType, rsaType) || other.rsaType == rsaType)&&(identical(other.useAppLock, useAppLock) || other.useAppLock == useAppLock)&&(identical(other.workHourStart, workHourStart) || other.workHourStart == workHourStart)&&(identical(other.workingDayTaskDensity, workingDayTaskDensity) || other.workingDayTaskDensity == workingDayTaskDensity)&&(identical(other.restDayTaskDensity, restDayTaskDensity) || other.restDayTaskDensity == restDayTaskDensity)&&(identical(other.planningHorizon, planningHorizon) || other.planningHorizon == planningHorizon)&&(identical(other.endPoint, endPoint) || other.endPoint == endPoint)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.aiDailySummary, aiDailySummary) || other.aiDailySummary == aiDailySummary)&&(identical(other.aiAnalyseReport, aiAnalyseReport) || other.aiAnalyseReport == aiAnalyseReport)&&(identical(other.aiTextToTask, aiTextToTask) || other.aiTextToTask == aiTextToTask)&&(identical(other.aiPicToTask, aiPicToTask) || other.aiPicToTask == aiPicToTask));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,themeMode,glassIntensity,language,tabNamingStyle,isNotificationEnabled,urgentNotificationStyle,approachingNotificationStyle,tempLeaveDuration,tempLeaveTimes,focusSceneRenderMode,focusSceneRenderQuality,useLogToTrain,syncEnabled,syncMode,syncTrigger,syncDurationOnInterval,rsaType,useAppLock,workHourStart,workingDayTaskDensity,restDayTaskDensity,planningHorizon,endPoint,modelName,aiDailySummary,aiAnalyseReport,aiTextToTask,aiPicToTask]);

@override
String toString() {
  return 'AppSettings(themeMode: $themeMode, glassIntensity: $glassIntensity, language: $language, tabNamingStyle: $tabNamingStyle, isNotificationEnabled: $isNotificationEnabled, urgentNotificationStyle: $urgentNotificationStyle, approachingNotificationStyle: $approachingNotificationStyle, tempLeaveDuration: $tempLeaveDuration, tempLeaveTimes: $tempLeaveTimes, focusSceneRenderMode: $focusSceneRenderMode, focusSceneRenderQuality: $focusSceneRenderQuality, useLogToTrain: $useLogToTrain, syncEnabled: $syncEnabled, syncMode: $syncMode, syncTrigger: $syncTrigger, syncDurationOnInterval: $syncDurationOnInterval, rsaType: $rsaType, useAppLock: $useAppLock, workHourStart: $workHourStart, workingDayTaskDensity: $workingDayTaskDensity, restDayTaskDensity: $restDayTaskDensity, planningHorizon: $planningHorizon, endPoint: $endPoint, modelName: $modelName, aiDailySummary: $aiDailySummary, aiAnalyseReport: $aiAnalyseReport, aiTextToTask: $aiTextToTask, aiPicToTask: $aiPicToTask)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 AppThemeMode themeMode, GlassIntensity glassIntensity, AppLanguage language, TabNamingStyle tabNamingStyle, bool isNotificationEnabled, UrgentNotificationStyle urgentNotificationStyle, ApproachingNotificationStyle approachingNotificationStyle, TempLeaveDuration tempLeaveDuration, TempLeaveTimes tempLeaveTimes, FocusSceneRenderMode focusSceneRenderMode, FocusSceneRenderQuality focusSceneRenderQuality, bool useLogToTrain, bool syncEnabled, SyncMode syncMode, SyncTrigger syncTrigger, Duration syncDurationOnInterval, RsaType rsaType, bool useAppLock,@TimeOfDayConverter() TimeOfDay workHourStart, WorkingDayTaskDensity workingDayTaskDensity, RestDayTaskDensity restDayTaskDensity, PlanningHorizon planningHorizon, String endPoint, String modelName, bool aiDailySummary, bool aiAnalyseReport, bool aiTextToTask, bool aiPicToTask
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? themeMode = null,Object? glassIntensity = null,Object? language = null,Object? tabNamingStyle = null,Object? isNotificationEnabled = null,Object? urgentNotificationStyle = null,Object? approachingNotificationStyle = null,Object? tempLeaveDuration = null,Object? tempLeaveTimes = null,Object? focusSceneRenderMode = null,Object? focusSceneRenderQuality = null,Object? useLogToTrain = null,Object? syncEnabled = null,Object? syncMode = null,Object? syncTrigger = null,Object? syncDurationOnInterval = null,Object? rsaType = null,Object? useAppLock = null,Object? workHourStart = null,Object? workingDayTaskDensity = null,Object? restDayTaskDensity = null,Object? planningHorizon = null,Object? endPoint = null,Object? modelName = null,Object? aiDailySummary = null,Object? aiAnalyseReport = null,Object? aiTextToTask = null,Object? aiPicToTask = null,}) {
  return _then(_AppSettings(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as AppThemeMode,glassIntensity: null == glassIntensity ? _self.glassIntensity : glassIntensity // ignore: cast_nullable_to_non_nullable
as GlassIntensity,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as AppLanguage,tabNamingStyle: null == tabNamingStyle ? _self.tabNamingStyle : tabNamingStyle // ignore: cast_nullable_to_non_nullable
as TabNamingStyle,isNotificationEnabled: null == isNotificationEnabled ? _self.isNotificationEnabled : isNotificationEnabled // ignore: cast_nullable_to_non_nullable
as bool,urgentNotificationStyle: null == urgentNotificationStyle ? _self.urgentNotificationStyle : urgentNotificationStyle // ignore: cast_nullable_to_non_nullable
as UrgentNotificationStyle,approachingNotificationStyle: null == approachingNotificationStyle ? _self.approachingNotificationStyle : approachingNotificationStyle // ignore: cast_nullable_to_non_nullable
as ApproachingNotificationStyle,tempLeaveDuration: null == tempLeaveDuration ? _self.tempLeaveDuration : tempLeaveDuration // ignore: cast_nullable_to_non_nullable
as TempLeaveDuration,tempLeaveTimes: null == tempLeaveTimes ? _self.tempLeaveTimes : tempLeaveTimes // ignore: cast_nullable_to_non_nullable
as TempLeaveTimes,focusSceneRenderMode: null == focusSceneRenderMode ? _self.focusSceneRenderMode : focusSceneRenderMode // ignore: cast_nullable_to_non_nullable
as FocusSceneRenderMode,focusSceneRenderQuality: null == focusSceneRenderQuality ? _self.focusSceneRenderQuality : focusSceneRenderQuality // ignore: cast_nullable_to_non_nullable
as FocusSceneRenderQuality,useLogToTrain: null == useLogToTrain ? _self.useLogToTrain : useLogToTrain // ignore: cast_nullable_to_non_nullable
as bool,syncEnabled: null == syncEnabled ? _self.syncEnabled : syncEnabled // ignore: cast_nullable_to_non_nullable
as bool,syncMode: null == syncMode ? _self.syncMode : syncMode // ignore: cast_nullable_to_non_nullable
as SyncMode,syncTrigger: null == syncTrigger ? _self.syncTrigger : syncTrigger // ignore: cast_nullable_to_non_nullable
as SyncTrigger,syncDurationOnInterval: null == syncDurationOnInterval ? _self.syncDurationOnInterval : syncDurationOnInterval // ignore: cast_nullable_to_non_nullable
as Duration,rsaType: null == rsaType ? _self.rsaType : rsaType // ignore: cast_nullable_to_non_nullable
as RsaType,useAppLock: null == useAppLock ? _self.useAppLock : useAppLock // ignore: cast_nullable_to_non_nullable
as bool,workHourStart: null == workHourStart ? _self.workHourStart : workHourStart // ignore: cast_nullable_to_non_nullable
as TimeOfDay,workingDayTaskDensity: null == workingDayTaskDensity ? _self.workingDayTaskDensity : workingDayTaskDensity // ignore: cast_nullable_to_non_nullable
as WorkingDayTaskDensity,restDayTaskDensity: null == restDayTaskDensity ? _self.restDayTaskDensity : restDayTaskDensity // ignore: cast_nullable_to_non_nullable
as RestDayTaskDensity,planningHorizon: null == planningHorizon ? _self.planningHorizon : planningHorizon // ignore: cast_nullable_to_non_nullable
as PlanningHorizon,endPoint: null == endPoint ? _self.endPoint : endPoint // ignore: cast_nullable_to_non_nullable
as String,modelName: null == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String,aiDailySummary: null == aiDailySummary ? _self.aiDailySummary : aiDailySummary // ignore: cast_nullable_to_non_nullable
as bool,aiAnalyseReport: null == aiAnalyseReport ? _self.aiAnalyseReport : aiAnalyseReport // ignore: cast_nullable_to_non_nullable
as bool,aiTextToTask: null == aiTextToTask ? _self.aiTextToTask : aiTextToTask // ignore: cast_nullable_to_non_nullable
as bool,aiPicToTask: null == aiPicToTask ? _self.aiPicToTask : aiPicToTask // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
