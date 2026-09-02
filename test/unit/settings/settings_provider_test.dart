import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/models/app_settings.dart';
import 'package:janus/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ─────────────────────────────────────────────────────────────────────────
  // settingsServiceProvider
  // ─────────────────────────────────────────────────────────────────────────
  group('settingsServiceProvider', () {
    test('provides a non-null SettingsService', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final service = container.read(settingsServiceProvider);

      expect(service, isNotNull);
    });

    test('is a singleton within the same container', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final a = container.read(settingsServiceProvider);
      final b = container.read(settingsServiceProvider);

      expect(a, same(b));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // appSettingsProvider
  // ─────────────────────────────────────────────────────────────────────────
  group('appSettingsProvider', () {
    /// Helper: wait for the notifier's async build to complete.
    Future<void> waitForInit(ProviderContainer container) async {
      await container.read(appSettingsProvider.notifier).future;
    }

    test('loads default settings initially', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      expect(container.read(appSettingsProvider).isLoading, true);

      await waitForInit(container);

      final settings = container.read(appSettingsProvider);
      expect(settings.hasValue, true);
      expect(settings.value!.themeMode, AppThemeMode.system);
    });

    test('setThemeMode updates the value and persists', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      await waitForInit(container);

      await container
          .read(appSettingsProvider.notifier)
          .setThemeMode(AppThemeMode.dark);

      expect(
        container.read(appSettingsProvider).value!.themeMode,
        AppThemeMode.dark,
      );
    });

    test('setGlassIntensity updates the value', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      await waitForInit(container);

      await container
          .read(appSettingsProvider.notifier)
          .setGlassIntensity(GlassIntensity.extreme);

      expect(
        container.read(appSettingsProvider).value!.glassIntensity,
        GlassIntensity.extreme,
      );
    });

    test('setLanguage updates the value', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      await waitForInit(container);

      await container
          .read(appSettingsProvider.notifier)
          .setLanguage(AppLanguage.english);

      expect(
        container.read(appSettingsProvider).value!.language,
        AppLanguage.english,
      );
    });

    test('setTabNamingStyle updates the value', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      await waitForInit(container);

      await container
          .read(appSettingsProvider.notifier)
          .setTabNamingStyle(TabNamingStyle.professional);

      expect(
        container.read(appSettingsProvider).value!.tabNamingStyle,
        TabNamingStyle.professional,
      );
    });

    test('multiple mutations persist independently', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      await waitForInit(container);

      final notifier = container.read(appSettingsProvider.notifier);

      await notifier.setThemeMode(AppThemeMode.dark);
      await notifier.setLanguage(AppLanguage.english);
      await notifier.setTabNamingStyle(TabNamingStyle.latin);

      final settings = container.read(appSettingsProvider).value!;
      expect(settings.themeMode, AppThemeMode.dark);
      expect(settings.language, AppLanguage.english);
      expect(settings.tabNamingStyle, TabNamingStyle.latin);
      expect(settings.glassIntensity, GlassIntensity.moderate); // ← unchanged
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // themeModeProvider
  // ─────────────────────────────────────────────────────────────────────────
  group('themeModeProvider', () {
    Future<void> waitForInit(ProviderContainer container) async {
      await container.read(appSettingsProvider.notifier).future;
    }

    test('defaults to ThemeMode.system', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      await waitForInit(container);

      expect(container.read(themeModeProvider), ThemeMode.system);
    });

    test('changes when AppSettingsNotifier updates theme', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      await waitForInit(container);

      await container
          .read(appSettingsProvider.notifier)
          .setThemeMode(AppThemeMode.light);

      expect(container.read(themeModeProvider), ThemeMode.light);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 其余 setter（通知 / 专注 / 数据 / 同步 / 规划 / AI / 用户偏好）
  // ─────────────────────────────────────────────────────────────────────────
  group('剩余 setter', () {
    Future<void> waitForInit(ProviderContainer container) async {
      await container.read(appSettingsProvider.notifier).future;
    }

    AppSettingsNotifier notifierOf(ProviderContainer container) =>
        container.read(appSettingsProvider.notifier);

    // 通知
    test('setNotificationEnabled 更新通知开关', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      await waitForInit(container);

      await notifierOf(container).setNotificationEnabled(true);

      expect(
        container.read(appSettingsProvider).value!.isNotificationEnabled,
        true,
      );
    });

    test('setUrgentNotificationStyle 更新紧急通知样式', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      await waitForInit(container);

      await notifierOf(
        container,
      ).setUrgentNotificationStyle(UrgentNotificationStyle.fullScreenNotifier);

      expect(
        container.read(appSettingsProvider).value!.urgentNotificationStyle,
        UrgentNotificationStyle.fullScreenNotifier,
      );
    });

    test('setApproachingNotificationStyle 更新临近通知样式', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      await waitForInit(container);

      await notifierOf(container).setApproachingNotificationStyle(
        ApproachingNotificationStyle.notifierAndRing,
      );

      expect(
        container.read(appSettingsProvider).value!.approachingNotificationStyle,
        ApproachingNotificationStyle.notifierAndRing,
      );
    });

    // 专注
    test('setTempLeaveDuration 更新临时离开时长', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      await waitForInit(container);

      await notifierOf(container).setTempLeaveDuration(TempLeaveDuration.fiveM);

      expect(
        container.read(appSettingsProvider).value!.tempLeaveDuration,
        TempLeaveDuration.fiveM,
      );
    });

    test('setTempLeaveTimes 更新临时离开次数', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      await waitForInit(container);

      await notifierOf(container).setTempLeaveTimes(TempLeaveTimes.fourTimes);

      expect(
        container.read(appSettingsProvider).value!.tempLeaveTimes,
        TempLeaveTimes.fourTimes,
      );
    });

    test('setFocusSceneRenderMode 更新渲染模式', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      await waitForInit(container);

      await notifierOf(
        container,
      ).setFocusSceneRenderMode(FocusSceneRenderMode.unity);

      expect(
        container.read(appSettingsProvider).value!.focusSceneRenderMode,
        FocusSceneRenderMode.unity,
      );
    });

    test('setFocusSceneRenderQuality 更新渲染质量', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      await waitForInit(container);

      await notifierOf(
        container,
      ).setFocusSceneRenderQuality(FocusSceneRenderQuality.high);

      expect(
        container.read(appSettingsProvider).value!.focusSceneRenderQuality,
        FocusSceneRenderQuality.high,
      );
    });

    // 数据
    test('setUseLogToTrain 更新日志训练开关', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      await waitForInit(container);

      await notifierOf(container).setUseLogToTrain(true);

      expect(container.read(appSettingsProvider).value!.useLogToTrain, true);
    });

    // 同步
    test('setSyncEnabled 更新同步开关', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      await waitForInit(container);

      await notifierOf(container).setSyncEnabled(true);

      expect(container.read(appSettingsProvider).value!.syncEnabled, true);
    });

    test('setSyncMode 更新同步模式', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      await waitForInit(container);

      await notifierOf(container).setSyncMode(SyncMode.localFirst);

      expect(
        container.read(appSettingsProvider).value!.syncMode,
        SyncMode.localFirst,
      );
    });

    test('setSyncTrigger 更新同步触发方式', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      await waitForInit(container);

      await notifierOf(container).setSyncTrigger(SyncTrigger.onChanged);

      expect(
        container.read(appSettingsProvider).value!.syncTrigger,
        SyncTrigger.onChanged,
      );
    });

    test('setSyncDurationOnInterval 更新同步间隔', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      await waitForInit(container);

      await notifierOf(
        container,
      ).setSyncDurationOnInterval(const Duration(hours: 1));

      expect(
        container.read(appSettingsProvider).value!.syncDurationOnInterval,
        const Duration(hours: 1),
      );
    });

    test('setRsaType 更新 RSA 类型', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      await waitForInit(container);

      await notifierOf(container).setRsaType(RsaType.rsa4096);

      expect(
        container.read(appSettingsProvider).value!.rsaType,
        RsaType.rsa4096,
      );
    });

    test('setUseAppLock 更新应用锁开关', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      await waitForInit(container);

      await notifierOf(container).setUseAppLock(true);

      expect(container.read(appSettingsProvider).value!.useAppLock, true);
    });

    // 规划
    test('setWorkingDayTaskDensity 更新工作日密度', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      await waitForInit(container);

      await notifierOf(
        container,
      ).setWorkingDayTaskDensity(WorkingDayTaskDensity.dense);

      expect(
        container.read(appSettingsProvider).value!.workingDayTaskDensity,
        WorkingDayTaskDensity.dense,
      );
    });

    test('setRestDayTaskDensity 更新休息日密度', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      await waitForInit(container);

      await notifierOf(
        container,
      ).setRestDayTaskDensity(RestDayTaskDensity.dense);

      expect(
        container.read(appSettingsProvider).value!.restDayTaskDensity,
        RestDayTaskDensity.dense,
      );
    });

    test('setPlanningHorizon 更新规划周期', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      await waitForInit(container);

      await notifierOf(container).setPlanningHorizon(PlanningHorizon.months);

      expect(
        container.read(appSettingsProvider).value!.planningHorizon,
        PlanningHorizon.months,
      );
    });

    // AI
    test('setUseAiDailySummary 更新 AI 日报开关', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      await waitForInit(container);

      await notifierOf(container).setUseAiDailySummary(true);

      expect(container.read(appSettingsProvider).value!.aiDailySummary, true);
    });

    test('setAiAnalyseReport 更新 AI 报告开关', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      await waitForInit(container);

      await notifierOf(container).setAiAnalyseReport(true);

      expect(container.read(appSettingsProvider).value!.aiAnalyseReport, true);
    });

    test('setAiTextToTask 更新 AI 文本转任务开关', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      await waitForInit(container);

      await notifierOf(container).setAiTextToTask(true);

      expect(container.read(appSettingsProvider).value!.aiTextToTask, true);
    });

    test('setAiPicToTask 更新 AI 图片转任务开关', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      await waitForInit(container);

      await notifierOf(container).setAiPicToTask(true);

      expect(container.read(appSettingsProvider).value!.aiPicToTask, true);
    });

    test('isValidAiEndpoint validates HTTPS requirement and loopback exceptions', () {
      expect(isValidAiEndpoint(''), isTrue);
      expect(isValidAiEndpoint('https://api.openai.com/v1'), isTrue);
      expect(isValidAiEndpoint('http://localhost:8080/v1'), isTrue);
      expect(isValidAiEndpoint('http://127.0.0.1:11434'), isTrue);
      expect(isValidAiEndpoint('http://[::1]:11434'), isTrue);

      // Insecure remote HTTP endpoints should fail validation
      expect(isValidAiEndpoint('http://api.openai.com/v1'), isFalse);
      expect(isValidAiEndpoint('http://192.168.1.100:8080'), isFalse);
      expect(isValidAiEndpoint('not-a-valid-url'), isFalse);
    });

    test('setEndPoint enforces HTTPS security rule for remote endpoints', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      await waitForInit(container);

      final notifier = notifierOf(container);

      // Secure HTTPS endpoint should succeed
      final successHttps = await notifier.setEndPoint('https://api.openai.com/v1');
      expect(successHttps, isTrue);
      expect(
        container.read(appSettingsProvider).value!.endPoint,
        'https://api.openai.com/v1',
      );

      // Insecure HTTP endpoint for remote host should be rejected
      final successHttp = await notifier.setEndPoint('http://insecure-api.com');
      expect(successHttp, isFalse);
      // Value should remain unchanged
      expect(
        container.read(appSettingsProvider).value!.endPoint,
        'https://api.openai.com/v1',
      );
    });

    // 用户偏好
    test('setTaskCreationMode 更新任务创建模式', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      await waitForInit(container);

      await notifierOf(
        container,
      ).setTaskCreationMode(TaskCreationMode.fillInBlanks);

      expect(
        container.read(appSettingsProvider).value!.taskCreationMode,
        TaskCreationMode.fillInBlanks,
      );
    });
  });
}
