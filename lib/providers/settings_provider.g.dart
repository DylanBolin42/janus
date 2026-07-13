// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsServiceHash() => r'95f01e6a33f7fbafdcb42b6855a64b0fd7eb39f7';

/// Provides the singleton [SettingsService] instance.
///
/// Copied from [settingsService].
@ProviderFor(settingsService)
final settingsServiceProvider = AutoDisposeProvider<SettingsService>.internal(
  settingsService,
  name: r'settingsServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SettingsServiceRef = AutoDisposeProviderRef<SettingsService>;
String _$themeModeHash() => r'693a142363301131a896240439e91c2326a7ee52';

/// Exposes the resolved [ThemeMode] so [MaterialApp] can react to changes
/// without watching the full [AppSettings] in main.dart.
///
/// Copied from [themeMode].
@ProviderFor(themeMode)
final themeModeProvider = AutoDisposeProvider<ThemeMode>.internal(
  themeMode,
  name: r'themeModeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$themeModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ThemeModeRef = AutoDisposeProviderRef<ThemeMode>;
String _$appSettingsNotifierHash() =>
    r'cac3b4ca9fc1d51caae7f0084e0de435ac42550f';

/// Async notifier that loads, exposes, and persists [AppSettings].
///
/// Every mutation calls [_persist] which saves to [shared_preferences]
/// then updates [state] so all watchers rebuild.
///
/// Copied from [AppSettingsNotifier].
@ProviderFor(AppSettingsNotifier)
final appSettingsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<AppSettingsNotifier, AppSettings>.internal(
      AppSettingsNotifier.new,
      name: r'appSettingsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$appSettingsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AppSettingsNotifier = AutoDisposeAsyncNotifier<AppSettings>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
