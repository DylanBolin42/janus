# 应用设置 (App Settings) 文档

本文档详细描述了 Janus 应用程序中所有可配置的设置项，包括其用途、可能的值、默认行为以及在代码中的定义位置。这些设置通过 `lib/models/app_settings.dart` 中的 `AppSettings` 模型进行管理，并使用 `shared_preferences` 进行持久化。

## 1. AppSettings 数据模型概览

`AppSettings` 是一个使用 `freezed` 包定义的不可变数据模型，它聚合了所有应用程序级别的设置。通过 `json_serializable`，该模型能够方便地与 JSON 格式进行序列化和反序列化，以便于存储和加载。

**定义文件:** `lib/models/app_settings.dart`

## 2. 通用设置 (General Settings)

| 设置项 | 类型 | 默认值 | 描述 | 相关枚举/扩展 |
| :--- | :--- | :--- | :--- | :--- |
| `themeMode` | `AppThemeMode` | `AppThemeMode.system` | 控制应用程序的整体主题模式：跟随系统、明亮模式或暗黑模式。 | `AppThemeModeX`, `AppThemeModeLabel` |
| `glassIntensity` | `GlassIntensity` | `GlassIntensity.moderate` | 控制应用程序中液态玻璃效果的渲染强度。 | `GlassIntensityLabel` |
| `language` | `AppLanguage` | `AppLanguage.chinese` | 控制应用程序的显示语言。 | `AppLanguageLabel` |
| `tabNamingStyle` | `TabNamingStyle` | `TabNamingStyle.classic` | 定义底部导航栏标签的命名风格。 | `TabNamingStyleLabel` |

### 2.1 `AppThemeMode` 枚举

表示应用程序的主题模式。

| 值 | JSON 值 | 描述 | UI 显示 |
| :--- | :--- | :--- | :--- |
| `system` | `system` | 跟随操作系统的主题设置。 | `跟随系统` |
| `light` | `light` | 强制使用明亮主题。 | `明亮模式` |
| `dark` | `dark` | 强制使用暗黑主题。 | `暗黑模式` |

### 2.2 `GlassIntensity` 枚举

表示液态玻璃效果的渲染强度。强度越高，视觉效果越明显，但可能消耗更多 GPU 资源。

| 值 | JSON 值 | 描述 | UI 显示 |
| :--- | :--- | :--- | :--- |
| `extreme` | `extreme` | 极致强度。 | `极致` |
| `moderate` | `moderate` | 适中强度。 | `适中` |
| `low` | `low` | 低强度。 | `低` |

### 2.3 `AppLanguage` 枚举

表示应用程序支持的显示语言。

| 值 | JSON 值 | 描述 | UI 显示 |
| :--- | :--- | :--- | :--- |
| `chinese` | `zh` | 简体中文。 | `中文` |
| `english` | `en` | 英文。 | `English` |

### 2.4 `TabNamingStyle` 枚举

表示底部导航栏标签的命名风格。

| 值 | JSON 值 | 描述 | UI 显示 |
| :--- | :--- | :--- | :--- |
| `classic` | `classic` | 经典命名风格。 | `经典` |
| `latin` | `latin` | 拉丁命名风格。 | `拉丁` |
| `professional` | `professional` | 专业命名风格。 | `专业` |

## 3. 通知设置 (Notification Settings)

| 设置项 | 类型 | 默认值 | 描述 | 相关枚举/扩展 |
| :--- | :--- | :--- | :--- | :--- |
| `isNotificationEnabled` | `bool` | `false` | 控制是否启用应用程序的通知功能。 | 无 |
| `urgentNotificationStyle` | `UrgentNotificationStyle` | `UrgentNotificationStyle.notifier` | 定义针对“紧迫项”的通知提醒方式。 | `UrgentNotificationStyleLabel` |
| `approachingNotificationStyle` | `ApproachingNotificationStyle` | `ApproachingNotificationStyle.notifier` | 定义针对“迫近项”的通知提醒方式。 | `ApproachingNotificationStyleLabel` |

### 3.1 `UrgentNotificationStyle` 枚举

表示紧迫项的通知提醒方式。

| 值 | JSON 值 | 描述 | UI 显示 |
| :--- | :--- | :--- | :--- |
| `notifier` | `notifier` | 仅通过通知栏提醒。 | `仅通知` |
| `notifierAndShake` | `notifierAndShake` | 通知栏提醒并伴随震动。 | `通知+震动` |
| `notifierAndRing` | `notifierAndRing` | 通知栏提醒并伴随响铃。 | `通知+响铃` |
| `fullScreenNotifier` | `FullScreenNotifier` | 全屏通知提醒。 | `全屏通知` |

### 3.2 `ApproachingNotificationStyle` 枚举

表示迫近项的通知提醒方式。

| 值 | JSON 值 | 描述 | UI 显示 |
| :--- | :--- | :--- | :--- |
| `notifier` | `notifier` | 仅通过通知栏提醒。 | `仅通知` |
| `notifierAndShake` | `notifierAndShake` | 通知栏提醒并伴随震动。 | `通知+震动` |
| `notifierAndRing` | `notifierAndRing` | 通知栏提醒并伴随响铃。 | `通知+响铃` |
| `fullScreenNotifier` | `FullScreenNotifier` | 全屏通知提醒。 | `全屏通知` |

## 4. 持久化机制

所有 `AppSettings` 中的设置项都通过 `lib/services/settings_service.dart` 中的 `SettingsService` 类，利用 `shared_preferences` 进行持久化。整个 `AppSettings` 对象被序列化为一个 JSON 字符串，并存储在 `shared_preferences` 的 `app_settings` 键下。

## 5. 状态管理与生效

`lib/providers/settings_provider.dart` 中的 `AppSettingsNotifier` (Riverpod) 负责加载、暴露和持久化 `AppSettings`。UI 组件通过监听 `AppSettingsNotifier` 来响应设置的变化。例如，`lib/main.dart` 中的 `MyApp` 监听 `themeModeProvider` 以动态应用主题。

**注意：** 部分设置项（如 `glassIntensity`, `language`, `tabNamingStyle`）在 `AppShell.dart` 中尚未完全动态应用，可能需要进一步的集成工作才能在主界面生效。
