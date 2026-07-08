# 新增设置项指南

## 概述

基于现有的 `shared_preferences` + `freezed` + `riverpod` 架构，添加一个新的设置项通常只需修改 **3 个现有文件**，**不需要新建任何文件**。

---

## 第一步：在 Model 中声明字段

**文件**: `lib/.../generalSetting/model/app_settings.dart`

### 场景 A：添加枚举型设置

```dart
// 1. 定义枚举（放在文件顶部的枚举区域）
enum ReminderInterval {
  @JsonValue('15min')
  fifteenMinutes,
  @JsonValue('30min')
  thirtyMinutes,
  @JsonValue('60min')
  sixtyMinutes,
}

// 2. 定义中文标签（放在枚举下方）
extension ReminderIntervalLabel on ReminderInterval {
  String get label {
    switch (this) {
      case ReminderInterval.fifteenMinutes:
        return '15 分钟';
      case ReminderInterval.thirtyMinutes:
        return '30 分钟';
      case ReminderInterval.sixtyMinutes:
        return '60 分钟';
    }
  }
}
```

### 场景 B：添加 bool/数值/字符串型设置

```dart
// 不需要枚举，直接在 AppSettings 中加字段即可
@Default(false) bool autoStartEnabled,         // bool
@Default(80)    double fontSize,               // 数值
@Default('')    String userName,               // 字符串
```

### 3. 在 `AppSettings` 上加字段

```dart
@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(AppThemeMode.system) AppThemeMode themeMode,
    @Default(GlassIntensity.moderate) GlassIntensity glassIntensity,
    @Default(AppLanguage.chinese) AppLanguage language,
    @Default(TabNamingStyle.classic) TabNamingStyle tabNamingStyle,
    @Default(ReminderInterval.thirtyMinutes) ReminderInterval reminderInterval, // ← 新增
  }) = _AppSettings;
```

> **为什么用 `@Default`？** 老用户本地 JSON 中没有这个字段，反序列化时自动回退到默认值，不会崩溃。

---

## 第二步：在 Notifier 上加 Setter

**文件**: `lib/.../generalSetting/providers/settings_provider.dart`

```dart
// 枚举型
Future<void> setReminderInterval(ReminderInterval interval) async {
  await _persist(
    (state.valueOrNull ?? const AppSettings())
        .copyWith(reminderInterval: interval),
  );
}

// bool 型
Future<void> setAutoStartEnabled(bool enabled) async {
  await _persist(
    (state.valueOrNull ?? const AppSettings())
        .copyWith(autoStartEnabled: enabled),
  );
}
```

`_persist` 会自动完成：`save()` 到 `shared_preferences` + 更新 `state` 通知所有监听者。

---

## 第三步：在 UI 中绑定

### 下拉菜单型（对应 `GlassPullDownButton`）

```dart
// 在 general_setting_page.dart 的对应 SettingsSection 中
SettingsTile(
  title: const Text('默认提醒间隔'),
  leading: const Icon(Icons.timer_rounded),
  trailing: GlassPullDownButton(
    label: settings.reminderInterval.label,     // 显示当前选中
    buttonWidth: 120,                            // 避免文字溢出
    items: ReminderInterval.values.map((interval) {
      return GlassMenuItem(
        title: interval.label,
        isSelected: settings.reminderInterval == interval,
        onTap: () => ref
            .read(appSettingsNotifierProvider.notifier)
            .setReminderInterval(interval),
      );
    }).toList(),
  ),
),
```

### 开关型（对应 `Switch`）

```dart
SettingsTile(
  title: const Text('自动启动'),
  leading: const Icon(Icons.power_settings_new_rounded),
  trailing: Switch(
    value: settings.autoStartEnabled,           // 当前值
    onChanged: (val) => ref                     // 更新
        .read(appSettingsNotifierProvider.notifier)
        .setAutoStartEnabled(val),
  ),
),
```

### 导航型（对应 `SettingsTile.navigation` → 跳转子页面）

```dart
SettingsTile.navigation(
  title: const Text('高级设置'),
  leading: const Icon(Icons.tune_rounded),
  onPressed: (_) => context.pushNamed('advancedSetting'),
),
```

---

## 第四步：运行代码生成

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

这步会重新生成 `app_settings.freezed.dart`（copyWith/==/hashCode）和 `app_settings.g.dart`（JSON 序列化）。Notifier 和 UI 不需要重新生成。

---

## 完整示例：从零到一添加「自动启动」开关

### 改 1: `app_settings.dart`

```dart
// 文件顶部不需要加枚举（bool 类型不需要）

// AppSettings 上加：
@Default(false) bool autoStartEnabled,
```

### 改 2: `settings_provider.dart`

```dart
// Notifier 中加：
Future<void> setAutoStartEnabled(bool enabled) async {
  await _persist(
    (state.valueOrNull ?? const AppSettings())
        .copyWith(autoStartEnabled: enabled),
  );
}
```

### 改 3: `general_setting_page.dart`

```dart
// 在「权限」section 中：
SettingsTile(
  title: const Text('自动启动'),
  leading: const Icon(Icons.power_settings_new_rounded),
  trailing: Switch(
    value: settings.autoStartEnabled,
    onChanged: (val) => ref
        .read(appSettingsNotifierProvider.notifier)
        .setAutoStartEnabled(val),
  ),
),
```

### 运行

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

**完成。** 3 个文件，每处加几行代码，不需要建新文件。

---

## 在不同页面中使用设置

非 `GeneralSettingPage` 的组件也可以随时读写设置：

```dart
// 任意 ConsumerWidget / ConsumerStatefulWidget 中：
final settings = ref.watch(appSettingsNotifierProvider).valueOrNull;

// 读取
if (settings?.autoStartEnabled == true) { ... }

// 写入
ref.read(appSettingsNotifierProvider.notifier).setAutoStartEnabled(false);
```

---

## 完整文件清单

| 文件 | 作用 | 每次加设置都要改？ |
|---|---|---|
| `model/app_settings.dart` | 枚举 + `AppSettings` 数据类 | ✅ 必改 |
| `providers/settings_provider.dart` | Notifier 的 setter 方法 | ✅ 必改 |
| `general_setting_page.dart` 或其他 UI 文件 | 界面展示与交互 | ✅ 必改 |
| `services/settings_service.dart` | 持久化逻辑 | ❌ 不需要 |
| `main.dart` | 应用入口 | ❌ 不需要 |
| 任何 `.freezed.dart` / `.g.dart` | 自动生成 | ❌ 不需要手动改 |

---

## 设计原则

1. **Immutable 模型** — `copyWith` 创建新实例，不修改旧对象
2. **单一数据源** — 所有组件通过 `appSettingsNotifierProvider` 获取/修改设置
3. **自动持久化** — Notifier 的 `_persist` 统一处理 `save + state`，不重复编写存储代码
4. **向后兼容** — `@Default` + `$enumDecodeNullable` 保证老数据不会因加字段而崩溃
