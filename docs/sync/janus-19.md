# JANUS-19 基础同步

- Linear: https://linear.app/zero-task-manager/issue/JANUS-19/
- GitHub: https://github.com/DylanBolin42/janus/issues/14
- 已审阅 PR #174 的同步页去占位实现；本次基于 main 独立实现，不引入 #174 的其他页面改动。没有真实请求结果时不会显示成功、虚假流量或已启用安全功能。

## 协议与数据

通过 `dart:io HttpClient` 实现 HTTPS WebDAV，Basic Authentication。目录必须已存在；PROPFIND（Depth: 0）验证目录，PUT 上传快照，GET 下载快照。拒绝 HTTP、URL 内嵌凭据、查询参数、重定向和无效 TLS 证书；连接超时 15 秒、单次 HTTP 请求总超时 30 秒、上传及响应限制 10 MiB。文件名仅允许字母、数字、下划线、连字符及 `.json` 后缀，防止路径越界。

JSON v1 顶层为 `version: 1`、`createdAt`（UTC ISO-8601）、`tasks`、`tags`、`settings`。任务/标签使用 Drift 行 JSON 字段（包括 ID、状态、DDL、预计耗时、优先级及标签），DDL 按 Drift 默认序列化为 epoch 毫秒。设置使用 AppSettings JSON，但不导出/导入同步开关、策略/触发间隔、RSA/应用锁偏好、AI 端点与模型名称。WebDAV 地址、用户名、密码不在 AppSettings 内。

这是完整替换快照：上传覆盖远端同名文件；下载替换本地任务、标签及可同步设置，两种操作都先提示并要求确认。不进行增量合并、跨设备 ID 合并或冲突解决；应使用单写入者，上传前确认没有其他设备更新。空快照也会清空本地任务。下次本地创建任务继续使用 SQLite 自增 ID。

导入先完整解析、验证版本、字段类型、ID/标签唯一性、任务标题、状态/优先级和耗时范围，再事务替换数据库。设置持久化失败回滚数据库，并尝试恢复原设置。数据库与 SharedPreferences 不具备跨存储事务：进程在提交窗口被杀死时不能保证两者完全原子，暂不提供崩溃恢复日志。

## 配置、安全与状态

保留已有页面分组；凭据字段可输入、保存与重进回显。启用手动同步须连通性检查成功并安全保存配置。每次实际操作再次校验配置及连接。现有 AppSettings 的 syncEnabled 保存手动同步开关；syncMode、syncTrigger、interval 保留在模型中，本页不会把这些尚未实现的行为描述为已生效。

未新增依赖，也未修改 pubspec、锁文件或 CI。使用 `janus/sync_credentials` MethodChannel：

- Android：Android Keystore 中的 AES 密钥、AES-GCM 随机 IV 加密；密文存于应用私有 noBackupFilesDir，临时文件替换，避免备份密文后丢失设备密钥。
- iOS：Generic Password Keychain item，`kSecAttrAccessibleWhenUnlockedThisDeviceOnly`；已有配置通过 SecItemUpdate 更新。
- 不回退至 SharedPreferences 或明文文件，不记录密码及底层错误详情。不支持的平台明确提示安全存储不可用；不会虚假启用。
- 尚未提供凭据删除操作、桌面/Web 的安全存储桥接。内存中的控制器随页面销毁。远端快照为明文 JSON，仅传输使用 TLS。

状态机：idle → connecting → syncing → success；任何异常进入 failed。检查成功只显示“连接验证通过，尚未传输数据”，不更新同步时间。上传收到成功 HTTP 状态、下载完成本地恢复后才记录时间，并显示具体结果。进度为不确定进度条；不展示编造的百分比或流量。失败可重试，同步中忽略重复请求并禁用配置编辑；下拉刷新读取本机持久化的上次成功传输时间（不访问远端）。该时间属于本机最近一次传输，修改配置后不代表新服务器已同步。

认证失败、无权限、404、服务器错误、超时、证书错误、网络错误、无效快照及存储失败有可读反馈。重试使用当前表单配置，替换操作再次确认。连接检查不等于已验证 PUT 权限；只有实际上传才可确认写入权限。

## 验证与限制

Flutter 3.47.0 / Dart 3.13.0（与 `.fvmrc` 一致），本分支最终验证：

- `fvm flutter test --no-pub`：224 项全过（含新增 19 项同步测试）。
- `fvm flutter analyze --no-pub`：6 项已有诊断，退出码 1；独立检出基线 d5f33fa 也为相同的 2 warning / 4 info，没有新增诊断。
- `fvm dart format --output=none --set-exit-if-changed`：10 个变更 Dart 文件无格式差异；`git diff --check` 通过。
- 没有 Android SDK/JDK、Xcode；原生桥接尚未编译，不将 mock 通道测试视为真机验证。

同步单元测试使用内存 Drift 数据库及注入的 FakeBackend，覆盖失败→重试、状态转换、并发拒绝、时间持久化、快照往返（含标签）、损坏快照/重复 ID 不修改本地数据、设置写入失败回滚、安全存储通道及失败时不明文回退。

协议测试启动本地 HTTPS HttpServer，测试专用自签名证书显式注入测试客户端信任；覆盖真实 PROPFIND/PUT/GET 路径与认证、401 重试、404/500、重定向拒绝、默认客户端拒绝不可信证书及 10 MiB 大小限制。`test/fixtures/sync` 中的密钥和证书仅用于本地测试，无生产用途，生产客户端没有关闭证书验证的代码。

Widget 测试覆盖原有页面、真实状态文案、配置回显、连接失败重试、取消/确认下载、非法快照错误、同步中进度。原生桥接通过 mock MethodChannel 验证 Dart 接口，不等于验证原生代码。

未做：自动/后台/间隔调度、自动合并、远端版本锁/ETag、数据加密、应用锁、远端目录创建、桌面/Web 安全存储、真实服务器联调。

需真机 + 真实服务器验证：

1. Android/iOS 原生编译与桥接注册；保存配置后重启，用户名和密码应回显。Android 检查没有明文配置、备份/恢复后不可解密时有失败提示；iOS 检查设备锁定时 Keychain 访问失败可恢复。
2. 使用有效证书及已有 WebDAV 目录，验证目录访问权限、非 ASCII 凭据及服务器兼容性；错误密码、缺少写入权限、断网/超时/过期证书应失败且不更新成功时间。
3. 先备份现有数据：上传、清空/修改本地后确认下载，核对任务状态、标签、耗时及设置；取消操作不更改数据，重复点击不并发请求，恢复后新增任务正常。
4. 两台设备分别手动上传/下载核对替换语义，禁止同时写入；重启/下拉刷新验证上次传输时间，不把连接检查当成同步成功。
5. 手机窄屏、长错误信息、键盘输入与下拉刷新手势实机检查。
