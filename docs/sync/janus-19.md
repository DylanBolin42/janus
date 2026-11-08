# JANUS-19 基础同步

> **快照明文包含任务标题、备注、标签及设置，传输安全依赖服务端 TLS 完整性与有效证书。服务器及其备份的访问者可以读取任务数据。当前没有客户端加密；本版仅适用于可信服务器上的单写入者、全量覆盖。**

- Linear: https://linear.app/zero-task-manager/issue/JANUS-19/
- GitHub: https://github.com/DylanBolin42/janus/issues/14
- 已审阅 PR #174 的同步页去占位实现；本次基于 main 独立实现，不引入 #174 的其他页面改动。没有真实请求结果时不会显示成功、虚假流量或已启用安全功能。

## 协议与数据

通过 `dart:io HttpClient` 实现 HTTPS WebDAV，Basic Authentication。目录必须已存在；PROPFIND（Depth: 0）验证目录，PUT 上传快照，GET 下载快照。拒绝 HTTP、URL 内嵌凭据、查询参数、重定向和无效 TLS 证书；连接超时 15 秒、单次 HTTP 请求总超时 30 秒、上传及响应限制 10 MiB。文件名仅允许字母、数字、下划线、连字符及 `.json` 后缀，防止路径越界。

JSON v1 顶层为 `version: 1`、`createdAt`（UTC ISO-8601）、`tasks`、`tags`、`settings`。任务/标签使用 Drift 行 JSON 字段（包括 ID、状态、DDL、预计耗时、优先级及标签），DDL 按 Drift 默认序列化为 epoch 毫秒。设置使用 AppSettings JSON，但不导出/导入同步开关、策略/触发间隔、RSA/应用锁偏好、AI 端点与模型名称。WebDAV 地址、用户名、密码不在 AppSettings 内。

这是完整替换快照：上传覆盖远端同名文件；下载替换本地任务、标签及可同步设置，两种操作都先提示并要求确认。不进行增量合并、跨设备 ID 合并或冲突解决；选择在 UI 和文档明确限制的方案，本版不新增 ETag 协议：现有数据没有跨设备版本基线，完整引入条件读写和冲突确认会扩大本次基础同步范围。无 ETag 保护，最后上传会覆盖之前的数据，必须使用单写入者。

操作规范：先备份本地与远端；停止其他设备编辑和上传；首次使用空目录时仅指定写入设备创建初始快照；此后写入设备先下载最新快照，再修改并上传；其他设备只在上传完成后下载，不能上传自己的旧副本。切换写入设备时，旧设备先上传并停止编辑，新设备再下载，之后才开始编辑。违反该流程可能永久丢失其他设备修改。空快照也会清空本地任务。下次本地创建任务继续使用 SQLite 自增 ID。

导入先完整解析、验证版本、字段类型、ID/标签唯一性、任务标题、状态/优先级和耗时范围，再事务替换数据库。设置持久化失败回滚数据库，并尝试恢复原设置。数据库与 SharedPreferences 不具备跨存储事务：进程在提交窗口被杀死时不能保证两者完全原子，暂不提供崩溃恢复日志。

## 配置、安全与状态

保留已有页面分组；凭据字段可输入、保存与重进回显。启用手动同步须连通性检查成功并安全保存配置。每次实际操作再次校验配置及连接。现有 AppSettings 的 syncEnabled 保存手动同步开关；syncMode、syncTrigger、interval 保留在模型中，本页不会把这些尚未实现的行为描述为已生效。

未新增依赖，未修改 pubspec、锁文件或 workflow。iOS 编译门禁由 PR #178 引入；它合入后，本 PR 必须重基并跑一次 iOS 构建确认 Keychain 桥接。使用 `janus/sync_credentials` MethodChannel：

- Android：Android Keystore 中的 AES 密钥、AES-GCM 随机 IV 加密；密文存于应用私有 noBackupFilesDir，临时文件替换，避免备份密文后丢失设备密钥。
- iOS：Generic Password Keychain item，`kSecAttrAccessibleWhenUnlockedThisDeviceOnly`；已有配置通过 SecItemUpdate 更新。
- 不回退至 SharedPreferences 或明文文件，不记录密码及底层错误详情。不支持的平台明确提示安全存储不可用；不会虚假启用。
- 尚未提供凭据删除操作、桌面/Web 的安全存储桥接。内存中的控制器随页面销毁。远端快照为明文 JSON，仅传输使用 TLS。

状态机：idle → connecting → syncing → success；任何异常进入 failed。检查成功只显示“连接验证通过，尚未传输数据”，不更新同步时间。上传收到成功 HTTP 状态、下载完成本地恢复后才记录时间，并显示具体结果。进度为不确定进度条；不展示编造的百分比或流量。失败可重试，同步中忽略重复请求并禁用配置编辑；下拉刷新读取本机持久化的上次成功传输时间（不访问远端）。该时间属于本机最近一次传输，修改配置后不代表新服务器已同步。

认证失败、无权限、404、服务器错误、超时、证书错误、网络错误、无效快照及存储失败有可读反馈。重试使用当前表单配置，替换操作再次确认。连接检查不等于已验证 PUT 权限；只有实际上传才可确认写入权限。

可选客户端加密评估：**TODO(JANUS-19)，本 PR 未实现**。安全版本至少需要经过审计的 AEAD（如 AES-GCM）、口令 KDF/盐值、带版本的加密信封、完整性校验与跨设备密钥备份/恢复约定；当前依赖中没有适合直接使用的完整方案。为避免自制密码算法和不可恢复的数据，本轮不提供看似可用的加密开关。以后只有在上述方案及篡改/错误密码/轮换测试完成后才能启用。HTTPS 不能防止服务端读取数据，本地 Keystore/Keychain 也不会加密远端快照。

并发边界：所有 SyncService（包括不同 ProviderContainer / 页面入口）在同一应用 isolate 内共享服务级同步锁，进入第一个 await 前同步获取；连接、传输、恢复和时间保存完成或失败后释放。第二入口明确失败并可稍后重试，销毁原入口也不会提前释放。它不是跨 isolate、跨进程或跨设备锁，不能替代单写入者规范。

## 验证与限制

Flutter 3.47.0 / Dart 3.13.0（与 `.fvmrc` 一致），本分支最终验证：

- `fvm flutter test --no-pub`：228 项全过（本轮增加 3 项共享锁回归及 1 项生产资源边界检查，累计 23 项同步专项测试）。
- `fvm flutter analyze --no-pub`：6 项已有诊断，退出码 1；独立检出基线 d5f33fa 也为相同的 2 warning / 4 info，没有新增诊断。
- `fvm dart format --output=none --set-exit-if-changed`：11 个变更 Dart 文件无格式差异；`git diff --check` 通过。
- Linux 沙箱实际尝试 `fvm flutter build ios --no-codesign`，退出码 64：`Could not find an option named "--no-codesign"`（Linux Flutter 不提供 iOS 构建子命令），未在本地编译 Keychain 桥接。
- **iOS 编译门禁由 #178 引入，它合入后本 PR 需重基并跑一次 iOS 构建确认 Keychain 桥接。** 为避免 workflow 冲突，本 PR 不新增或修改构建 job。iOS 编译仍未验证，尤其 AppDelegate 的 registrar、Security 常量/CFDictionary、SecItem API 类型兼容性必须由该构建确认；签名、Keychain 真机访问和生命周期注册仍须设备验证。mock 通道测试不等于原生验证。
- Android 原生桥接上一轮 GitHub CI 编译通过；本轮将再次检查。
- `fvm flutter build bundle --release --target-platform linux-x64 --no-pub` 成功，随后 `python3 scripts/check_sync_test_assets.py build/flutter_assets` 确认生产资源包没有测试证书/私钥。检查脚本另以干净 ZIP、重命名后的私钥 ZIP、重命名后的证书目录验证了放行/拒绝行为。

同步单元测试使用内存 Drift 数据库及注入的 FakeBackend，覆盖失败→重试、状态转换、并发拒绝、时间持久化、快照往返（含标签）、损坏快照/重复 ID 不修改本地数据、设置写入失败回滚、安全存储通道及失败时不明文回退。

协议测试启动本地 HTTPS HttpServer，测试专用自签名证书显式注入测试客户端信任；覆盖真实 PROPFIND/PUT/GET 路径与认证、401 重试、404/500、重定向拒绝、默认客户端拒绝不可信证书及 10 MiB 大小限制。`test/fixtures/sync` 中的密钥和证书仅用于本地测试，无生产用途，生产客户端没有关闭证书验证的代码。它们只由测试从文件系统读取，pubspec 的生产 assets/fonts 不包含 test 路径，lib/ 与原生代码也不引用 fixture。`scripts/check_sync_test_assets.py` 可在 Android APK、iOS Runner.app 或生产 Flutter 资源目录构建后扫描条目路径及 fixture 完整内容，发现泄露以非零退出（也检查重命名后仍含相同内容的文件）。本轮不改 workflow，脚本不自动挂入 CI；全量 Flutter 测试中也断言 AssetManifest 无 fixture 且 rootBundle 无法加载测试证书/私钥。本地另以生产资源包验证，实际原生包可用 `python3 scripts/check_sync_test_assets.py <APK 或 Runner.app 路径>` 复核。

Widget 测试覆盖原有页面、真实状态文案、配置回显、连接失败重试、取消/确认下载、非法快照错误、同步中进度。原生桥接通过 mock MethodChannel 验证 Dart 接口，不等于验证原生代码。

未做：自动/后台/间隔调度、自动合并、远端版本锁/ETag、数据加密、应用锁、远端目录创建、桌面/Web 安全存储、真实服务器联调。

需真机 + 真实服务器验证：

1. Android/iOS 原生编译与桥接注册；保存配置后重启，用户名和密码应回显。Android 检查没有明文配置、备份/恢复后不可解密时有失败提示；iOS 检查设备锁定时 Keychain 访问失败可恢复。
2. 使用有效证书及已有 WebDAV 目录，验证目录访问权限、非 ASCII 凭据及服务器兼容性；错误密码、缺少写入权限、断网/超时/过期证书应失败且不更新成功时间。
3. 先备份现有数据：上传、清空/修改本地后确认下载，核对任务状态、标签、耗时及设置；取消操作不更改数据，重复点击不并发请求，恢复后新增任务正常。
4. 两台设备分别手动上传/下载核对替换语义，禁止同时写入；重启/下拉刷新验证上次传输时间，不把连接检查当成同步成功。
5. 手机窄屏、长错误信息、键盘输入与下拉刷新手势实机检查。

手动 iOS 编译与桥接复核：在安装 Xcode 与 CocoaPods 的 Mac 上使用本分支，执行 `fvm flutter pub get`、`fvm flutter build ios --release --no-codesign`，确认没有 AppDelegate 的 Flutter registrar、Security 常量/CFDictionary 或 SecItem API 类型错误。再签名安装到设备，首次读无配置应返回空；保存/更新/重启应返回新配置；设备锁定/解锁后的 Keychain 不可用与恢复应有反馈。
