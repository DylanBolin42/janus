// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) {
  return _AppSettings.fromJson(json);
}

/// @nodoc
mixin _$AppSettings {
  // Gereral settings
  AppThemeMode get themeMode => throw _privateConstructorUsedError;
  GlassIntensity get glassIntensity => throw _privateConstructorUsedError;
  AppLanguage get language => throw _privateConstructorUsedError;
  TabNamingStyle get tabNamingStyle =>
      throw _privateConstructorUsedError; // Notification settings
  bool get isNotificationEnabled => throw _privateConstructorUsedError;
  UrgentNotificationStyle get urgentNotificationStyle =>
      throw _privateConstructorUsedError;
  ApproachingNotificationStyle get approachingNotificationStyle =>
      throw _privateConstructorUsedError; // Focus settings
  TempLeaveDuration get tempLeaveDuration => throw _privateConstructorUsedError;
  TempLeaveTimes get tempLeaveTimes => throw _privateConstructorUsedError;
  FocusSceneRenderMode get focusSceneRenderMode =>
      throw _privateConstructorUsedError;
  FocusSceneRenderQuality get focusSceneRenderQuality =>
      throw _privateConstructorUsedError; // Storage settings
  bool get useLogToTrain => throw _privateConstructorUsedError; // Sync settings
  bool get syncEnabled => throw _privateConstructorUsedError;
  SyncMode get syncMode => throw _privateConstructorUsedError;
  SyncTrigger get syncTrigger => throw _privateConstructorUsedError;
  Duration get syncDurationOnInterval => throw _privateConstructorUsedError;
  RsaType get rsaType => throw _privateConstructorUsedError;
  bool get useAppLock =>
      throw _privateConstructorUsedError; // Planning settings
  @TimeOfDayConverter()
  TimeOfDay get workHourStart => throw _privateConstructorUsedError;
  WorkingDayTaskDensity get workingDayTaskDensity =>
      throw _privateConstructorUsedError;
  RestDayTaskDensity get restDayTaskDensity =>
      throw _privateConstructorUsedError;
  PlanningHorizon get planningHorizon =>
      throw _privateConstructorUsedError; // AI settings
  String get endPoint =>
      throw _privateConstructorUsedError; //INFO: API Key通过安全存储持久化
  String get modelName => throw _privateConstructorUsedError;
  bool get aiDailySummary => throw _privateConstructorUsedError;
  bool get aiAnalyseReport => throw _privateConstructorUsedError;
  bool get aiTextToTask => throw _privateConstructorUsedError;
  bool get aiPicToTask => throw _privateConstructorUsedError;

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppSettingsCopyWith<AppSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppSettingsCopyWith<$Res> {
  factory $AppSettingsCopyWith(
    AppSettings value,
    $Res Function(AppSettings) then,
  ) = _$AppSettingsCopyWithImpl<$Res, AppSettings>;
  @useResult
  $Res call({
    AppThemeMode themeMode,
    GlassIntensity glassIntensity,
    AppLanguage language,
    TabNamingStyle tabNamingStyle,
    bool isNotificationEnabled,
    UrgentNotificationStyle urgentNotificationStyle,
    ApproachingNotificationStyle approachingNotificationStyle,
    TempLeaveDuration tempLeaveDuration,
    TempLeaveTimes tempLeaveTimes,
    FocusSceneRenderMode focusSceneRenderMode,
    FocusSceneRenderQuality focusSceneRenderQuality,
    bool useLogToTrain,
    bool syncEnabled,
    SyncMode syncMode,
    SyncTrigger syncTrigger,
    Duration syncDurationOnInterval,
    RsaType rsaType,
    bool useAppLock,
    @TimeOfDayConverter() TimeOfDay workHourStart,
    WorkingDayTaskDensity workingDayTaskDensity,
    RestDayTaskDensity restDayTaskDensity,
    PlanningHorizon planningHorizon,
    String endPoint,
    String modelName,
    bool aiDailySummary,
    bool aiAnalyseReport,
    bool aiTextToTask,
    bool aiPicToTask,
  });
}

/// @nodoc
class _$AppSettingsCopyWithImpl<$Res, $Val extends AppSettings>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? glassIntensity = null,
    Object? language = null,
    Object? tabNamingStyle = null,
    Object? isNotificationEnabled = null,
    Object? urgentNotificationStyle = null,
    Object? approachingNotificationStyle = null,
    Object? tempLeaveDuration = null,
    Object? tempLeaveTimes = null,
    Object? focusSceneRenderMode = null,
    Object? focusSceneRenderQuality = null,
    Object? useLogToTrain = null,
    Object? syncEnabled = null,
    Object? syncMode = null,
    Object? syncTrigger = null,
    Object? syncDurationOnInterval = null,
    Object? rsaType = null,
    Object? useAppLock = null,
    Object? workHourStart = null,
    Object? workingDayTaskDensity = null,
    Object? restDayTaskDensity = null,
    Object? planningHorizon = null,
    Object? endPoint = null,
    Object? modelName = null,
    Object? aiDailySummary = null,
    Object? aiAnalyseReport = null,
    Object? aiTextToTask = null,
    Object? aiPicToTask = null,
  }) {
    return _then(
      _value.copyWith(
            themeMode: null == themeMode
                ? _value.themeMode
                : themeMode // ignore: cast_nullable_to_non_nullable
                      as AppThemeMode,
            glassIntensity: null == glassIntensity
                ? _value.glassIntensity
                : glassIntensity // ignore: cast_nullable_to_non_nullable
                      as GlassIntensity,
            language: null == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as AppLanguage,
            tabNamingStyle: null == tabNamingStyle
                ? _value.tabNamingStyle
                : tabNamingStyle // ignore: cast_nullable_to_non_nullable
                      as TabNamingStyle,
            isNotificationEnabled: null == isNotificationEnabled
                ? _value.isNotificationEnabled
                : isNotificationEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            urgentNotificationStyle: null == urgentNotificationStyle
                ? _value.urgentNotificationStyle
                : urgentNotificationStyle // ignore: cast_nullable_to_non_nullable
                      as UrgentNotificationStyle,
            approachingNotificationStyle: null == approachingNotificationStyle
                ? _value.approachingNotificationStyle
                : approachingNotificationStyle // ignore: cast_nullable_to_non_nullable
                      as ApproachingNotificationStyle,
            tempLeaveDuration: null == tempLeaveDuration
                ? _value.tempLeaveDuration
                : tempLeaveDuration // ignore: cast_nullable_to_non_nullable
                      as TempLeaveDuration,
            tempLeaveTimes: null == tempLeaveTimes
                ? _value.tempLeaveTimes
                : tempLeaveTimes // ignore: cast_nullable_to_non_nullable
                      as TempLeaveTimes,
            focusSceneRenderMode: null == focusSceneRenderMode
                ? _value.focusSceneRenderMode
                : focusSceneRenderMode // ignore: cast_nullable_to_non_nullable
                      as FocusSceneRenderMode,
            focusSceneRenderQuality: null == focusSceneRenderQuality
                ? _value.focusSceneRenderQuality
                : focusSceneRenderQuality // ignore: cast_nullable_to_non_nullable
                      as FocusSceneRenderQuality,
            useLogToTrain: null == useLogToTrain
                ? _value.useLogToTrain
                : useLogToTrain // ignore: cast_nullable_to_non_nullable
                      as bool,
            syncEnabled: null == syncEnabled
                ? _value.syncEnabled
                : syncEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            syncMode: null == syncMode
                ? _value.syncMode
                : syncMode // ignore: cast_nullable_to_non_nullable
                      as SyncMode,
            syncTrigger: null == syncTrigger
                ? _value.syncTrigger
                : syncTrigger // ignore: cast_nullable_to_non_nullable
                      as SyncTrigger,
            syncDurationOnInterval: null == syncDurationOnInterval
                ? _value.syncDurationOnInterval
                : syncDurationOnInterval // ignore: cast_nullable_to_non_nullable
                      as Duration,
            rsaType: null == rsaType
                ? _value.rsaType
                : rsaType // ignore: cast_nullable_to_non_nullable
                      as RsaType,
            useAppLock: null == useAppLock
                ? _value.useAppLock
                : useAppLock // ignore: cast_nullable_to_non_nullable
                      as bool,
            workHourStart: null == workHourStart
                ? _value.workHourStart
                : workHourStart // ignore: cast_nullable_to_non_nullable
                      as TimeOfDay,
            workingDayTaskDensity: null == workingDayTaskDensity
                ? _value.workingDayTaskDensity
                : workingDayTaskDensity // ignore: cast_nullable_to_non_nullable
                      as WorkingDayTaskDensity,
            restDayTaskDensity: null == restDayTaskDensity
                ? _value.restDayTaskDensity
                : restDayTaskDensity // ignore: cast_nullable_to_non_nullable
                      as RestDayTaskDensity,
            planningHorizon: null == planningHorizon
                ? _value.planningHorizon
                : planningHorizon // ignore: cast_nullable_to_non_nullable
                      as PlanningHorizon,
            endPoint: null == endPoint
                ? _value.endPoint
                : endPoint // ignore: cast_nullable_to_non_nullable
                      as String,
            modelName: null == modelName
                ? _value.modelName
                : modelName // ignore: cast_nullable_to_non_nullable
                      as String,
            aiDailySummary: null == aiDailySummary
                ? _value.aiDailySummary
                : aiDailySummary // ignore: cast_nullable_to_non_nullable
                      as bool,
            aiAnalyseReport: null == aiAnalyseReport
                ? _value.aiAnalyseReport
                : aiAnalyseReport // ignore: cast_nullable_to_non_nullable
                      as bool,
            aiTextToTask: null == aiTextToTask
                ? _value.aiTextToTask
                : aiTextToTask // ignore: cast_nullable_to_non_nullable
                      as bool,
            aiPicToTask: null == aiPicToTask
                ? _value.aiPicToTask
                : aiPicToTask // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppSettingsImplCopyWith<$Res>
    implements $AppSettingsCopyWith<$Res> {
  factory _$$AppSettingsImplCopyWith(
    _$AppSettingsImpl value,
    $Res Function(_$AppSettingsImpl) then,
  ) = __$$AppSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    AppThemeMode themeMode,
    GlassIntensity glassIntensity,
    AppLanguage language,
    TabNamingStyle tabNamingStyle,
    bool isNotificationEnabled,
    UrgentNotificationStyle urgentNotificationStyle,
    ApproachingNotificationStyle approachingNotificationStyle,
    TempLeaveDuration tempLeaveDuration,
    TempLeaveTimes tempLeaveTimes,
    FocusSceneRenderMode focusSceneRenderMode,
    FocusSceneRenderQuality focusSceneRenderQuality,
    bool useLogToTrain,
    bool syncEnabled,
    SyncMode syncMode,
    SyncTrigger syncTrigger,
    Duration syncDurationOnInterval,
    RsaType rsaType,
    bool useAppLock,
    @TimeOfDayConverter() TimeOfDay workHourStart,
    WorkingDayTaskDensity workingDayTaskDensity,
    RestDayTaskDensity restDayTaskDensity,
    PlanningHorizon planningHorizon,
    String endPoint,
    String modelName,
    bool aiDailySummary,
    bool aiAnalyseReport,
    bool aiTextToTask,
    bool aiPicToTask,
  });
}

/// @nodoc
class __$$AppSettingsImplCopyWithImpl<$Res>
    extends _$AppSettingsCopyWithImpl<$Res, _$AppSettingsImpl>
    implements _$$AppSettingsImplCopyWith<$Res> {
  __$$AppSettingsImplCopyWithImpl(
    _$AppSettingsImpl _value,
    $Res Function(_$AppSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? glassIntensity = null,
    Object? language = null,
    Object? tabNamingStyle = null,
    Object? isNotificationEnabled = null,
    Object? urgentNotificationStyle = null,
    Object? approachingNotificationStyle = null,
    Object? tempLeaveDuration = null,
    Object? tempLeaveTimes = null,
    Object? focusSceneRenderMode = null,
    Object? focusSceneRenderQuality = null,
    Object? useLogToTrain = null,
    Object? syncEnabled = null,
    Object? syncMode = null,
    Object? syncTrigger = null,
    Object? syncDurationOnInterval = null,
    Object? rsaType = null,
    Object? useAppLock = null,
    Object? workHourStart = null,
    Object? workingDayTaskDensity = null,
    Object? restDayTaskDensity = null,
    Object? planningHorizon = null,
    Object? endPoint = null,
    Object? modelName = null,
    Object? aiDailySummary = null,
    Object? aiAnalyseReport = null,
    Object? aiTextToTask = null,
    Object? aiPicToTask = null,
  }) {
    return _then(
      _$AppSettingsImpl(
        themeMode: null == themeMode
            ? _value.themeMode
            : themeMode // ignore: cast_nullable_to_non_nullable
                  as AppThemeMode,
        glassIntensity: null == glassIntensity
            ? _value.glassIntensity
            : glassIntensity // ignore: cast_nullable_to_non_nullable
                  as GlassIntensity,
        language: null == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as AppLanguage,
        tabNamingStyle: null == tabNamingStyle
            ? _value.tabNamingStyle
            : tabNamingStyle // ignore: cast_nullable_to_non_nullable
                  as TabNamingStyle,
        isNotificationEnabled: null == isNotificationEnabled
            ? _value.isNotificationEnabled
            : isNotificationEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        urgentNotificationStyle: null == urgentNotificationStyle
            ? _value.urgentNotificationStyle
            : urgentNotificationStyle // ignore: cast_nullable_to_non_nullable
                  as UrgentNotificationStyle,
        approachingNotificationStyle: null == approachingNotificationStyle
            ? _value.approachingNotificationStyle
            : approachingNotificationStyle // ignore: cast_nullable_to_non_nullable
                  as ApproachingNotificationStyle,
        tempLeaveDuration: null == tempLeaveDuration
            ? _value.tempLeaveDuration
            : tempLeaveDuration // ignore: cast_nullable_to_non_nullable
                  as TempLeaveDuration,
        tempLeaveTimes: null == tempLeaveTimes
            ? _value.tempLeaveTimes
            : tempLeaveTimes // ignore: cast_nullable_to_non_nullable
                  as TempLeaveTimes,
        focusSceneRenderMode: null == focusSceneRenderMode
            ? _value.focusSceneRenderMode
            : focusSceneRenderMode // ignore: cast_nullable_to_non_nullable
                  as FocusSceneRenderMode,
        focusSceneRenderQuality: null == focusSceneRenderQuality
            ? _value.focusSceneRenderQuality
            : focusSceneRenderQuality // ignore: cast_nullable_to_non_nullable
                  as FocusSceneRenderQuality,
        useLogToTrain: null == useLogToTrain
            ? _value.useLogToTrain
            : useLogToTrain // ignore: cast_nullable_to_non_nullable
                  as bool,
        syncEnabled: null == syncEnabled
            ? _value.syncEnabled
            : syncEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        syncMode: null == syncMode
            ? _value.syncMode
            : syncMode // ignore: cast_nullable_to_non_nullable
                  as SyncMode,
        syncTrigger: null == syncTrigger
            ? _value.syncTrigger
            : syncTrigger // ignore: cast_nullable_to_non_nullable
                  as SyncTrigger,
        syncDurationOnInterval: null == syncDurationOnInterval
            ? _value.syncDurationOnInterval
            : syncDurationOnInterval // ignore: cast_nullable_to_non_nullable
                  as Duration,
        rsaType: null == rsaType
            ? _value.rsaType
            : rsaType // ignore: cast_nullable_to_non_nullable
                  as RsaType,
        useAppLock: null == useAppLock
            ? _value.useAppLock
            : useAppLock // ignore: cast_nullable_to_non_nullable
                  as bool,
        workHourStart: null == workHourStart
            ? _value.workHourStart
            : workHourStart // ignore: cast_nullable_to_non_nullable
                  as TimeOfDay,
        workingDayTaskDensity: null == workingDayTaskDensity
            ? _value.workingDayTaskDensity
            : workingDayTaskDensity // ignore: cast_nullable_to_non_nullable
                  as WorkingDayTaskDensity,
        restDayTaskDensity: null == restDayTaskDensity
            ? _value.restDayTaskDensity
            : restDayTaskDensity // ignore: cast_nullable_to_non_nullable
                  as RestDayTaskDensity,
        planningHorizon: null == planningHorizon
            ? _value.planningHorizon
            : planningHorizon // ignore: cast_nullable_to_non_nullable
                  as PlanningHorizon,
        endPoint: null == endPoint
            ? _value.endPoint
            : endPoint // ignore: cast_nullable_to_non_nullable
                  as String,
        modelName: null == modelName
            ? _value.modelName
            : modelName // ignore: cast_nullable_to_non_nullable
                  as String,
        aiDailySummary: null == aiDailySummary
            ? _value.aiDailySummary
            : aiDailySummary // ignore: cast_nullable_to_non_nullable
                  as bool,
        aiAnalyseReport: null == aiAnalyseReport
            ? _value.aiAnalyseReport
            : aiAnalyseReport // ignore: cast_nullable_to_non_nullable
                  as bool,
        aiTextToTask: null == aiTextToTask
            ? _value.aiTextToTask
            : aiTextToTask // ignore: cast_nullable_to_non_nullable
                  as bool,
        aiPicToTask: null == aiPicToTask
            ? _value.aiPicToTask
            : aiPicToTask // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppSettingsImpl extends _AppSettings {
  const _$AppSettingsImpl({
    this.themeMode = AppThemeMode.system,
    this.glassIntensity = GlassIntensity.moderate,
    this.language = AppLanguage.chinese,
    this.tabNamingStyle = TabNamingStyle.classic,
    this.isNotificationEnabled = false,
    this.urgentNotificationStyle = UrgentNotificationStyle.notifier,
    this.approachingNotificationStyle = ApproachingNotificationStyle.notifier,
    this.tempLeaveDuration = TempLeaveDuration.tenM,
    this.tempLeaveTimes = TempLeaveTimes.twice,
    this.focusSceneRenderMode = FocusSceneRenderMode.rive,
    this.focusSceneRenderQuality = FocusSceneRenderQuality.medium,
    this.useLogToTrain = false,
    this.syncEnabled = false,
    this.syncMode = SyncMode.auto,
    this.syncTrigger = SyncTrigger.onTime,
    this.syncDurationOnInterval = const Duration(hours: 3),
    this.rsaType = RsaType.rsa2048,
    this.useAppLock = false,
    @TimeOfDayConverter()
    this.workHourStart = const TimeOfDay(hour: 8, minute: 0),
    this.workingDayTaskDensity = WorkingDayTaskDensity.medium,
    this.restDayTaskDensity = RestDayTaskDensity.loose,
    this.planningHorizon = PlanningHorizon.weeks,
    this.endPoint = '',
    this.modelName = '',
    this.aiDailySummary = false,
    this.aiAnalyseReport = false,
    this.aiTextToTask = false,
    this.aiPicToTask = false,
  }) : super._();

  factory _$AppSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppSettingsImplFromJson(json);

  // Gereral settings
  @override
  @JsonKey()
  final AppThemeMode themeMode;
  @override
  @JsonKey()
  final GlassIntensity glassIntensity;
  @override
  @JsonKey()
  final AppLanguage language;
  @override
  @JsonKey()
  final TabNamingStyle tabNamingStyle;
  // Notification settings
  @override
  @JsonKey()
  final bool isNotificationEnabled;
  @override
  @JsonKey()
  final UrgentNotificationStyle urgentNotificationStyle;
  @override
  @JsonKey()
  final ApproachingNotificationStyle approachingNotificationStyle;
  // Focus settings
  @override
  @JsonKey()
  final TempLeaveDuration tempLeaveDuration;
  @override
  @JsonKey()
  final TempLeaveTimes tempLeaveTimes;
  @override
  @JsonKey()
  final FocusSceneRenderMode focusSceneRenderMode;
  @override
  @JsonKey()
  final FocusSceneRenderQuality focusSceneRenderQuality;
  // Storage settings
  @override
  @JsonKey()
  final bool useLogToTrain;
  // Sync settings
  @override
  @JsonKey()
  final bool syncEnabled;
  @override
  @JsonKey()
  final SyncMode syncMode;
  @override
  @JsonKey()
  final SyncTrigger syncTrigger;
  @override
  @JsonKey()
  final Duration syncDurationOnInterval;
  @override
  @JsonKey()
  final RsaType rsaType;
  @override
  @JsonKey()
  final bool useAppLock;
  // Planning settings
  @override
  @JsonKey()
  @TimeOfDayConverter()
  final TimeOfDay workHourStart;
  @override
  @JsonKey()
  final WorkingDayTaskDensity workingDayTaskDensity;
  @override
  @JsonKey()
  final RestDayTaskDensity restDayTaskDensity;
  @override
  @JsonKey()
  final PlanningHorizon planningHorizon;
  // AI settings
  @override
  @JsonKey()
  final String endPoint;
  //INFO: API Key通过安全存储持久化
  @override
  @JsonKey()
  final String modelName;
  @override
  @JsonKey()
  final bool aiDailySummary;
  @override
  @JsonKey()
  final bool aiAnalyseReport;
  @override
  @JsonKey()
  final bool aiTextToTask;
  @override
  @JsonKey()
  final bool aiPicToTask;

  @override
  String toString() {
    return 'AppSettings(themeMode: $themeMode, glassIntensity: $glassIntensity, language: $language, tabNamingStyle: $tabNamingStyle, isNotificationEnabled: $isNotificationEnabled, urgentNotificationStyle: $urgentNotificationStyle, approachingNotificationStyle: $approachingNotificationStyle, tempLeaveDuration: $tempLeaveDuration, tempLeaveTimes: $tempLeaveTimes, focusSceneRenderMode: $focusSceneRenderMode, focusSceneRenderQuality: $focusSceneRenderQuality, useLogToTrain: $useLogToTrain, syncEnabled: $syncEnabled, syncMode: $syncMode, syncTrigger: $syncTrigger, syncDurationOnInterval: $syncDurationOnInterval, rsaType: $rsaType, useAppLock: $useAppLock, workHourStart: $workHourStart, workingDayTaskDensity: $workingDayTaskDensity, restDayTaskDensity: $restDayTaskDensity, planningHorizon: $planningHorizon, endPoint: $endPoint, modelName: $modelName, aiDailySummary: $aiDailySummary, aiAnalyseReport: $aiAnalyseReport, aiTextToTask: $aiTextToTask, aiPicToTask: $aiPicToTask)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppSettingsImpl &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.glassIntensity, glassIntensity) ||
                other.glassIntensity == glassIntensity) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.tabNamingStyle, tabNamingStyle) ||
                other.tabNamingStyle == tabNamingStyle) &&
            (identical(other.isNotificationEnabled, isNotificationEnabled) ||
                other.isNotificationEnabled == isNotificationEnabled) &&
            (identical(
                  other.urgentNotificationStyle,
                  urgentNotificationStyle,
                ) ||
                other.urgentNotificationStyle == urgentNotificationStyle) &&
            (identical(
                  other.approachingNotificationStyle,
                  approachingNotificationStyle,
                ) ||
                other.approachingNotificationStyle ==
                    approachingNotificationStyle) &&
            (identical(other.tempLeaveDuration, tempLeaveDuration) ||
                other.tempLeaveDuration == tempLeaveDuration) &&
            (identical(other.tempLeaveTimes, tempLeaveTimes) ||
                other.tempLeaveTimes == tempLeaveTimes) &&
            (identical(other.focusSceneRenderMode, focusSceneRenderMode) ||
                other.focusSceneRenderMode == focusSceneRenderMode) &&
            (identical(
                  other.focusSceneRenderQuality,
                  focusSceneRenderQuality,
                ) ||
                other.focusSceneRenderQuality == focusSceneRenderQuality) &&
            (identical(other.useLogToTrain, useLogToTrain) ||
                other.useLogToTrain == useLogToTrain) &&
            (identical(other.syncEnabled, syncEnabled) ||
                other.syncEnabled == syncEnabled) &&
            (identical(other.syncMode, syncMode) ||
                other.syncMode == syncMode) &&
            (identical(other.syncTrigger, syncTrigger) ||
                other.syncTrigger == syncTrigger) &&
            (identical(other.syncDurationOnInterval, syncDurationOnInterval) ||
                other.syncDurationOnInterval == syncDurationOnInterval) &&
            (identical(other.rsaType, rsaType) || other.rsaType == rsaType) &&
            (identical(other.useAppLock, useAppLock) ||
                other.useAppLock == useAppLock) &&
            (identical(other.workHourStart, workHourStart) ||
                other.workHourStart == workHourStart) &&
            (identical(other.workingDayTaskDensity, workingDayTaskDensity) ||
                other.workingDayTaskDensity == workingDayTaskDensity) &&
            (identical(other.restDayTaskDensity, restDayTaskDensity) ||
                other.restDayTaskDensity == restDayTaskDensity) &&
            (identical(other.planningHorizon, planningHorizon) ||
                other.planningHorizon == planningHorizon) &&
            (identical(other.endPoint, endPoint) ||
                other.endPoint == endPoint) &&
            (identical(other.modelName, modelName) ||
                other.modelName == modelName) &&
            (identical(other.aiDailySummary, aiDailySummary) ||
                other.aiDailySummary == aiDailySummary) &&
            (identical(other.aiAnalyseReport, aiAnalyseReport) ||
                other.aiAnalyseReport == aiAnalyseReport) &&
            (identical(other.aiTextToTask, aiTextToTask) ||
                other.aiTextToTask == aiTextToTask) &&
            (identical(other.aiPicToTask, aiPicToTask) ||
                other.aiPicToTask == aiPicToTask));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    themeMode,
    glassIntensity,
    language,
    tabNamingStyle,
    isNotificationEnabled,
    urgentNotificationStyle,
    approachingNotificationStyle,
    tempLeaveDuration,
    tempLeaveTimes,
    focusSceneRenderMode,
    focusSceneRenderQuality,
    useLogToTrain,
    syncEnabled,
    syncMode,
    syncTrigger,
    syncDurationOnInterval,
    rsaType,
    useAppLock,
    workHourStart,
    workingDayTaskDensity,
    restDayTaskDensity,
    planningHorizon,
    endPoint,
    modelName,
    aiDailySummary,
    aiAnalyseReport,
    aiTextToTask,
    aiPicToTask,
  ]);

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      __$$AppSettingsImplCopyWithImpl<_$AppSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppSettingsImplToJson(this);
  }
}

abstract class _AppSettings extends AppSettings {
  const factory _AppSettings({
    final AppThemeMode themeMode,
    final GlassIntensity glassIntensity,
    final AppLanguage language,
    final TabNamingStyle tabNamingStyle,
    final bool isNotificationEnabled,
    final UrgentNotificationStyle urgentNotificationStyle,
    final ApproachingNotificationStyle approachingNotificationStyle,
    final TempLeaveDuration tempLeaveDuration,
    final TempLeaveTimes tempLeaveTimes,
    final FocusSceneRenderMode focusSceneRenderMode,
    final FocusSceneRenderQuality focusSceneRenderQuality,
    final bool useLogToTrain,
    final bool syncEnabled,
    final SyncMode syncMode,
    final SyncTrigger syncTrigger,
    final Duration syncDurationOnInterval,
    final RsaType rsaType,
    final bool useAppLock,
    @TimeOfDayConverter() final TimeOfDay workHourStart,
    final WorkingDayTaskDensity workingDayTaskDensity,
    final RestDayTaskDensity restDayTaskDensity,
    final PlanningHorizon planningHorizon,
    final String endPoint,
    final String modelName,
    final bool aiDailySummary,
    final bool aiAnalyseReport,
    final bool aiTextToTask,
    final bool aiPicToTask,
  }) = _$AppSettingsImpl;
  const _AppSettings._() : super._();

  factory _AppSettings.fromJson(Map<String, dynamic> json) =
      _$AppSettingsImpl.fromJson;

  // Gereral settings
  @override
  AppThemeMode get themeMode;
  @override
  GlassIntensity get glassIntensity;
  @override
  AppLanguage get language;
  @override
  TabNamingStyle get tabNamingStyle; // Notification settings
  @override
  bool get isNotificationEnabled;
  @override
  UrgentNotificationStyle get urgentNotificationStyle;
  @override
  ApproachingNotificationStyle get approachingNotificationStyle; // Focus settings
  @override
  TempLeaveDuration get tempLeaveDuration;
  @override
  TempLeaveTimes get tempLeaveTimes;
  @override
  FocusSceneRenderMode get focusSceneRenderMode;
  @override
  FocusSceneRenderQuality get focusSceneRenderQuality; // Storage settings
  @override
  bool get useLogToTrain; // Sync settings
  @override
  bool get syncEnabled;
  @override
  SyncMode get syncMode;
  @override
  SyncTrigger get syncTrigger;
  @override
  Duration get syncDurationOnInterval;
  @override
  RsaType get rsaType;
  @override
  bool get useAppLock; // Planning settings
  @override
  @TimeOfDayConverter()
  TimeOfDay get workHourStart;
  @override
  WorkingDayTaskDensity get workingDayTaskDensity;
  @override
  RestDayTaskDensity get restDayTaskDensity;
  @override
  PlanningHorizon get planningHorizon; // AI settings
  @override
  String get endPoint; //INFO: API Key通过安全存储持久化
  @override
  String get modelName;
  @override
  bool get aiDailySummary;
  @override
  bool get aiAnalyseReport;
  @override
  bool get aiTextToTask;
  @override
  bool get aiPicToTask;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
