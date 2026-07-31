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
String _$themeModeHash() => r'fc03ea92664c25bb60892302289229fb1c17341c';

/// Exposes the resolved [ThemeMode] so [MaterialApp] can react to changes
/// without watching the full [AppSettings] in main.dart.
///
/// **Optimization:** By using Riverpod's [select] feature, this provider only
/// triggers a rebuild when the [themeMode] field actually changes. This prevents
/// the entire app widget tree (including routing and AppShell) from rebuilding
/// whenever other unrelated settings (such as AI, sync, or storage) are updated.
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
    r'14b2b74752bc17519bea3c1f60494ee86e5a8bf1';

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
