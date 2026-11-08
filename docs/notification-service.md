# JANUS-60 Notification Service（部分实现）

关联：https://linear.app/zero-task-manager/issue/JANUS-60/notification-service 、https://github.com/DylanBolin42/janus/issues/175

本 PR 仅交付通知调度基础设施，**不代表 JANUS-60 整体完成**。

## 已实现

- 复用 `AppSettings.isNotificationEnabled` 与两种通知强度。未新增平行的通知偏好。
- 任务 DDL 前 24 小时临近提醒、前 6 小时紧迫提醒（6 小时与 TaskCard 一致）。仅 status=0/2，跳过已到提醒时间、逾期、完成、冻结任务，不补发历史通知。
- `notificationSyncProvider` 订阅 taskDao 的任务流与持久化设置，启动、任务修改/完成/删除、设置变更和回到前台时重排。串行操作避免旧快照覆盖新快照。
- 默认隐私模式：通知只显示“有任务即将到期”，正文为空，payload 也不包含任务标题。仅在调用方得到明确同意后，以 `NotificationService(..., showTaskTitles: true)` 显式开启标题；当前应用默认不传此参数，没有增加平行偏好或默认开启标题。Android 额外使用 private 锁屏可见性；iOS 预览由系统控制，默认通用内容避免暴露标题。
- ID 明确保留任务范围 `0x4A000002..0x4AFFFFFF`（数据库任务 ID 1..0x7FFFFF，每项两个槽）与倒计时 `0x4B000001`，`0x4B000000..0x4B0000FF` 预留专注使用。其他通知生产者必须避开这些范围。取消/替换还验证 `janus.notifications.v2` payload 归属，碰撞报错而非覆盖第三方请求；只迁移带旧 `janus.task` 标记的待投递请求，不再按正负号清理所有通知。超出可编码数据库 ID 的任务跳过调度；已展示的历史通知不属于 pending 迁移。
- 固定任务 ID 与包含时间、最终显示文案、样式的 payload 指纹去重；插件持久化待投递请求，重启服务后仍可去重。取消过时请求、替换已编辑请求。
- `scheduleCountdown(endsAt, settings)`/`cancelCountdown()` 提供绝对结束时间的倒计时调度、替换、取消及权限/过期检查，与任务重排共用串行队列。
- Android/iOS 本地横幅平台适配；权限只在用户打开通知时申请。拒绝时不打开偏好；设置页区分偏好、系统授权与调度失败。回到前台重新检查授权。
- Android POST_NOTIFICATIONS、SCHEDULE_EXACT_ALARM、RECEIVE_BOOT_COMPLETED 与插件重启 receiver、通知图标及资源保留配置。无精确闹钟授权时使用 inexactAllowWhileIdle，可能延迟；已授权则使用 exactAllowWhileIdle。没有强行弹出特殊权限页。
- iOS 设置通知中心 delegate，在前台请求横幅展示；所有调度使用 UTC 绝对时间避免本地时区/DST 歧义。

## 未完成/需真机验证

- **专注通知：TODO**。当前 Focuspage 是 Placeholder，无专注会话/计时器模型。Android 常驻专注通知及 iOS ActivityKit/Widget Extension 均未实现，未暴露虚假的启用/成功 API。iOS 还需签名、Extension target、entitlements、原生桥接和会话结束清理。
- **倒计时：部分完成**。调度 API 和测试已实现，但没有真实计时器可以接线；未来在开始、暂停、重置、结束事件调用对应 API。只有倒计时调度 API 不能视为用户已可用的完整倒计时功能。
- **后台/开机：部分完成**。使用 OS 持久化调度和 Android receiver，而非承诺常驻 Dart 进程。本地没有设备、Android SDK 或 Xcode；Android 编译结果以 PR 对应 head 的 CI 为准，真实通知展示、杀进程和开机恢复仍需真机验证。iOS 依赖系统保存 pending 请求，不支持承诺应用开机自启。
- **容量**：任务只调度最近 60 条，预留 iOS 64 条上限中的 4 条。超出部分需下次前台恢复或数据/设置变化补排；尚无后台滚动补排。长期不打开应用、系统撤销精确闹钟授权、force-stop 或厂商省电策略均可能影响投递。
- **通知强度**：全屏选项明确降级为横幅，未实现 full-screen intent 特权；iOS 无独立的“仅震动”通知控制，不能保证震动。最终声响、横幅受系统通知渠道、勿扰和用户设置控制。
- 当前 main 的每日简报时间控件尚未绑定 AppSettings，不属于本次三项提醒功能；未新增或假装已有早晚简报调度。

## 依赖与配置

新增 pubspec 直接依赖 `flutter_local_notifications ^21.0.0`（系统持久化通知与 Android receiver）、`timezone ^0.11.0`（绝对时间调度）。Android Gradle 增加通知插件必需的 core library desugaring（desugar_jdk_libs 2.1.4），不变更已有 SDK/插件版本。本轮已准备 macOS `Build iOS Check`（`flutter build ios --release --no-codesign`）及 PR Summary 集成补丁，但 GitHub 拒绝推送工作流修改：OAuth 凭据缺少 `workflow` scope。实际工作流保持不变，现有 Android 编译门禁保留；待有工作流写权限的人应用 `docs/ios-native-build-gate.patch` 才会生效。遵循任务约束，不提交 pubspec.lock 等依赖版本文件；执行 pub get 会生成新增包的解析记录。

## iOS 原生编译验证状态

**本地未经过 iOS 原生编译验证**：Linux 沙箱无 Xcode。已实际运行 `fvm flutter build ios --no-codesign`，Flutter 返回 `Could not find an option named "--no-codesign"`，未进入 Swift 编译。补充 `import UserNotifications` 明确引入 `UNUserNotificationCenter` 所属模块，但源码检查不能替代编译。

当前 PR 没有生效的 iOS 编译门禁，**未经过 iOS 原生编译验证**。门禁补丁在 `docs/ios-native-build-gate.patch`，可由有工作流写权限的人用 `git apply docs/ios-native-build-gate.patch` 应用。CI 原生编译缺口是合入风险，不能由现有 Android CI 或 Dart 测试消除。即使未来无签名构建通过，也未验证 ActivityKit（未实现）、签名、设备权限及通知展示。

手动复核：在安装 Xcode/iOS SDK 的 macOS 上 checkout PR 的完整 head，执行 `xcodebuild -version`、`fvm install`、`fvm flutter pub get`、`fvm flutter build ios --release --no-codesign`；保留完整日志与 commit SHA，确认 Runner 与本地通知插件编译/链接成功，再在已签名真机安装中验证前后台横幅。失败时不能只凭 Dart 测试宣布 iOS 可用。

## 验证与人工清单

自动验证使用 `.fvmrc` 的 Flutter 3.47.0：`fvm flutter test`、`fvm flutter analyze`、`fvm dart format`。调度测试覆盖时间边界、状态筛选、容量、设置样式、进程重建去重、修改/删除/取消/重排、串行失败恢复、默认隐私/显式标题及替换、ID 边界/第三方保留/旧调度迁移/碰撞、倒计时、Provider 联动和 Android 平台通道的授权/精确闹钟降级。平台通道 mock 不是原生设备验证。

发布前请在 Android 与 iOS 真机检查：

1. 首次授权、拒绝、设置内撤销后回到前台；界面不得表示已获授权，关闭通知应取消所有待提醒。
2. 将任务截止时间设为当前时间后 24 小时加 2 分钟或 6 小时加 2 分钟，验证约 2 分钟后横幅；编辑 DDL/标题/强度、完成、冻结、删除后旧提醒不得出现。
3. Android 精确闹钟授权有/无两种状态，锁屏、Doze、省电、杀进程、重启、应用更新；检查是否恢复及实际延迟。force-stop 后需手动启动，不能承诺投递。
4. iOS 前后台、锁屏、勿扰及横幅/声音权限变化；跨时区/DST 后保持同一绝对截止时间。
5. 集成真实计时器后测试倒计时开始、重置、暂停、结束与重启；集成专注原生能力后再验证 Android 常驻通知、iOS 灵动岛生命周期。
6. 默认锁屏/前台通知及 payload 均不含任务标题，显式 opt-in 与返回隐私模式后旧待投递内容被替换。
7. 超过 60 条提醒的容量/补排行为，以及 Android release 构建的通知图标资源保留。
