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
  AppThemeMode get themeMode => throw _privateConstructorUsedError;
  GlassIntensity get glassIntensity => throw _privateConstructorUsedError;
  AppLanguage get language => throw _privateConstructorUsedError;
  TabNamingStyle get tabNamingStyle => throw _privateConstructorUsedError;

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
  }) : super._();

  factory _$AppSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppSettingsImplFromJson(json);

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

  @override
  String toString() {
    return 'AppSettings(themeMode: $themeMode, glassIntensity: $glassIntensity, language: $language, tabNamingStyle: $tabNamingStyle)';
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
                other.tabNamingStyle == tabNamingStyle));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    themeMode,
    glassIntensity,
    language,
    tabNamingStyle,
  );

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
  }) = _$AppSettingsImpl;
  const _AppSettings._() : super._();

  factory _AppSettings.fromJson(Map<String, dynamic> json) =
      _$AppSettingsImpl.fromJson;

  @override
  AppThemeMode get themeMode;
  @override
  GlassIntensity get glassIntensity;
  @override
  AppLanguage get language;
  @override
  TabNamingStyle get tabNamingStyle;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
