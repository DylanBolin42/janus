# JANUS-18 本地存储协议

沿用 PR #174 的真实计数、失败重试、删除前确认、事务清空和设置保留行为。本次增加完成数、真实文件大小、JSON 快照及导入恢复；不包含智能备份、同步、训练或迁移实现。

## 快照 v1

UTF-8 JSON 对象包含以下必填字段：

- `formatVersion`: 整数 `1`，用于演进快照格式。
- `schemaVersion`: 当前数据库版本 `3`；当前不执行跨版本迁移，不匹配时拒绝导入。
- `createdAt`: UTC ISO-8601 导出时间。
- `tasks`: 任务数组，每项包含 `id`, `status`, `title`, `description`, `ddl`, `estHour`, `estMinute`, `priority`, `tags`。
- `tags`: 标签数组，每项包含 `id`, `name`。

记录采用 Drift JSON 序列化。`ddl` 为 Unix epoch 毫秒整数；`tags` 为字符串数组或 null。`description`、`estHour`、`estMinute` 可为 null，但键必须存在。id 保留，必须为正整数且在各表中唯一；标签名非空且唯一；任务标题非空；status 为 -1/0/1/2；priority 为 0–3；预计时间必须同时为空或同时有效（小时 0–23、分钟 0–59）。不包含 SharedPreferences 中的应用设置、数据库表结构、SQLite 文件或其他资源。

## 文件与恢复操作

导出在同一个读事务内获得任务和标签，写入应用文档目录 `janus_snapshots/janus_<UTC微秒时间戳>.json.tmp`，flush 后同目录 rename 为 `.json`。失败清理临时文件。数据库不被修改。

“导入数据库”通过系统文件选择器选择任意提供方的 JSON；“应用内快照”列出该目录的 `.json` 文件。两种来源共用校验与确认流程。完整读取和验证后展示任务/标签数，用户确认才在一个事务中删除当前数据并插入快照。取消、读取失败、格式/版本/字段错误均不修改数据库；写入中途失败回滚全部删除与插入。Drift 通知已有查询流；本页操作后重新读取统计。设置保留，表结构保留。

错误消息区分无效 JSON、根节点错误、格式版本、数据库版本、时间戳、数组/字段缺失、字段类型、记录无效/重复，以及文件读写/权限错误。数据库失败显示可重试提示；统计读取失败提供重试入口。

`StorageRepository` 为未来策略和同步复用预留接口；当前实现为 `StorageService`。

## 文件来源与权限路径

- **系统导入**：“导入数据库”调用 `file_picker` 的单文件 JSON 选择器，不要求用户把文件搬入应用目录。选择器抽象 `StorageFilePicker` 返回 `SnapshotSource`（大小、字节流、释放回调），`StorageTransfer` 完成只读校验后才把快照交给页面确认。取消显示取消提示；选中但不可读、提供方失败和权限拒绝显示错误，不写数据库。
- **应用内导入**：“应用内快照”列出应用文档目录 `janus_snapshots` 的 JSON，通过同一有界流读取与格式校验管线恢复。无需重新申请外部文件权限。
- **Android**：插件原生代码用系统文档选择器取得临时 URI 授权，以 `ContentResolver.openInputStream(contentUri)` 复制到应用私有缓存，Dart 使用插件返回的读取流。应用不对 `content://` 调用 `File`，不把 URI 当绝对路径，不申请整个外部存储权限，也不保存需要续期的 URI。用完仅删除本次所选缓存文件（确认位于应用临时目录内）。
- **iOS**：插件使用 `UIDocumentPickerModeImport`，系统先提供应用拥有的 Inbox 副本，插件移到临时目录。读取副本后释放；不保存原始提供方 URL，因此无需跨会话安全作用域书签。iCloud 文件下载/临时复制由系统和插件执行，失败返回错误。macOS 补齐 `com.apple.security.files.user-selected.read-write` entitlement，读写系统面板选择的文件。
- **系统导出**：“导出数据库”先生成应用内恢复快照，然后用 `saveFile(bytes: ...)` 让用户选择名称/位置。Android 由插件通过 ContentResolver 写入目标 URI，iOS 由系统文档导出面板导出 staging 文件，桌面由插件写入选择的路径；应用不重新解释返回的标识符。取消会明确提示系统保存取消、应用内副本保留；失败也保留应用内副本。iOS staging 文件在返回后按精确文件名清理，绝不清空整个应用临时目录。
- **大小与编码**：导入上限 20 MiB；先检查已知大小，再逐块累计，即使提供方大小未知或谎报也无法绕过。超限取消订阅并释放来源，UTF-8 解码/JSON 解析只在大小检查后进行。应用内导入同样受限。系统导出超过 20 MiB 时明确拒绝传递 bytes 并提示已保留本地快照。插件在原生层可能先完整复制/下载文件到缓存；此限制保证 Dart 内存读取有界，不能阻止提供方原生下载阶段的磁盘开销。复制失败、磁盘不足都不会进入数据库写事务。

### 依赖选择

新增 `file_picker: ^10.3.10`（锁定 10.3.10）。选择已有 Android SAF 缓存读取、iOS Import 副本及桌面保存面板的成熟跨平台实现，避免自行维护多套原生 URI/授权代码。上游项目持续维护（已有更新大版本）；本次选用兼容当前 iOS 13 工程的 10.x API，插件 podspec 最低 iOS 12，不提升部署目标。当前最新 13.x 的 Darwin 实现要求 iOS 14，因此未采用。

包下载归档实测约 20 MiB（包含示例与媒体），解包约 22 MiB；lib/Android/iOS/macOS 源码目录合计约 400 KiB。它们都不是最终安装包增量。iOS 还包含 DKImagePickerController/DKPhotoGallery 等上游媒体依赖，即使本页面只选 JSON，也有 Pod 维护和体积成本；精确 APK/IPA 增量需要同配置原生 release 构建比较，本沙箱没有 Android SDK/Xcode，不虚报数字。锁文件新增 cross_file、dbus、flutter_plugin_android_lifecycle、petitparser、win32、xml 传递依赖，没有升级现有包。锁文件 Dart 下限变为 3.13，项目指定 Flutter 3.47.0 已自带 Dart 3.13，CI 配置无需修改。

## 占用口径

通过 `PRAGMA database_list` 查找实际主库位置，累加主库和存在的 `-wal`、`-shm` 文件字节数。这是文件长度的即时值，不是目录/整个应用占用，也不是压缩体积；读取不到或内存库显示不可用。删除记录不承诺立刻缩小 SQLite 文件。

## 真机待验

- Android/iOS/桌面真实系统选择器的取消、授权拒绝和保存位置选择；Android Downloads/云盘 content URI、iOS Files/iCloud 的导入副本及临时授权；macOS 沙箱 entitlement。
- 导出到用户所选位置并从该位置重新导入；取消/写入失败仍保留应用内快照；重启后应用内快照列表仍存在，在不同设备恢复字段和时间一致。
- 空快照、取消导入、损坏快照、数据库版本不匹配时提示与数据保留；确认导入后主页任务列表更新。
- 清空后任务/标签为零，可继续创建，设置不变；真实 SQLite/WAL 文件大小显示。
- 本实现依赖原生文件系统；Web 文件导入导出不在本次范围。
