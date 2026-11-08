# Insight 回顾数据口径（JANUS-12）

Insight 保留 AppShell 的导航和 CustomAppbar，只替换原 Placeholder 内容。

## 数据承载

`insightTasksProvider` 订阅 `TaskDao.watchAllTasks()`，包含完成和冻结任务。
`InsightSummary` 将任务按本地日历的截止日期筛选到 `[start, end)`，按截止时间、id 排序。
周从周一开始，月从一号开始；前后翻页和周/月切换都重新从同一实时数据计算。
“任务流水”是这份快照的有序列表，不是任务状态变更或专注事件日志。
不另存聚合副本，数据库更新、删除和重新进入页面都从真实存储回显。

## 指标

- 已完成：本期截止任务中当前 `status == 1` 的数量，不能理解为本期发生的完成事件。
- 当前完成占比：已完成 / 非冻结任务。没有分母时显示 `—`。
- 逾期未完成：非完成、非冻结且截止时间早于现在的任务。
- 预估工作量：非冻结任务的 `estHour * 60 + estMinute`，同时展示填写覆盖数。
  缺失预估值不贡献时长；该数不是实际专注时长。
- 实际专注、连续天数、历史趋势：显示中性说明，不以 0 或模拟数字冒充真实结果。

## 后续数据底座：JANUS-63

1. `database/task_tables.dart` 缺 `completedAt`；`TaskDao.editTask` 的完成与撤销路径需要维护。
   历史达成率还需要状态事件或每日快照，以避免修改当前状态后重写历史。
2. FocusPage 目前仍为 Placeholder，没有实际专注数据或读取 DAO。
   JANUS-63 需先补专注时段持久化表（taskId、startedAt、endedAt、有效秒数、取消状态）、
   AppDatabase 迁移、DAO 及 Focus 写入，再接入回顾并按周期边界裁剪时段。
   本次不临时杜撰专注接口，不引入 schema 变更。

## 风格与可访问性

参照 `theme/theme.dart` 的 AppSpacing、CardTheme、ChipTheme、TextTheme 和 ColorScheme，
以及 Inbox 的主题取值方式；使用主题化 filled 卡片、ChoiceChip、tonal 按钮。
不在页面定义颜色、字号或圆角，不新增主题或依赖。AppShell/CustomAppbar 继续负责标题与导航。
标题/数字使用 titleMedium/headlineMedium 的既有字号反差。
卡片纵向排版无固定高度，周期标题可换行、周期选择可 Wrap，整页可滚动，底部留 AppSpacing.bottomSafeArea。
同一主题来源保证与其他页面同步；320 逻辑像素宽、2 倍字号、深浅主题由 widget 测试覆盖。

## 验证范围

单测覆盖周/月跨年、闰月、半开区间、冻结/空数据分母、排序与统计口径。
Widget 测试覆盖真实内存 Drift 更新、周期往返、周/月切换、loading/error/retry 及深浅主题大字号。
设备上的触摸体验和真实 Android/iOS 数据库文件未人工验证。

## 重新生成渲染参考

运行 `bash scripts/capture_insight.sh /tmp/janus-insight-reference`。脚本仅使用现有依赖，
将临时测试放在被忽略的 `.dart_tool` 下，退出时清理；不会加入常规 analyze/build/test 发现路径。
输出深浅两张 PNG，使用两项明确的测试夹具，不含用户真实数据。
Headless 环境额外加载既有字体并为 TextTheme 提供 CJK 回退；个别控件仍可能与设备字体不同。
这是一项人工复现工具，不是新增的黄金图断言或真机验证。

## 当前快照与历史回顾的界限

本版是 **按 DDL 归组的当前快照**，没有冻结过去周期的状态。今天完成、撤销完成、
修改 DDL 或删除任务，都会重新计算并改写旧周期结果；旧周期的“已完成”不是当时完成数量。
页面也明确展示这条说明。归组用任务 DDL，**不使用完成日**。

JANUS-63 的 [PR #186](https://github.com/DylanBolin42/janus/pull/186) 已提出 completedAt 与事件表，
但尚未合并，本实现不引用其中的类型、表或分支。
#186 合入后，可通过独立历史查询按完成时间/完成事件归组，结合撤销语义改为历史回顾；
届时应一起修改页面口径与测试，不能只把当前快照的 DDL 替换成 completedAt 后继续称为历史快照。
#186 也修改 `database_provider.dart`，合并时需保留本次独立的 autoDispose 回顾流。

## 本地时区与 DST

周界线是当前本地时区的周一 00:00，月界线是本地一号 00:00；区间为起点包含、终点排除。
DDL 是时刻，用其与本地边界对应的绝对时刻比较。UTC 输入锚点先转换为本地日历。
相邻周用日历日期构造，不能在起点直接加固定 168 小时：America/New_York 的
2026-03-02 至 03-09 为 167 小时，2026-10-26 至 11-02 为 169 小时。
切换本地时区后，同一 DDL 可能归到不同周期；重新进入/重建页面按新时区重新算，
本次未加入 OS 时区变更事件监听，不承诺保持页面不动时自动刷新。

`insight_timezone_test.dart` 在独立的纯 Dart 子进程中分别设置 UTC、Asia/Shanghai、
America/New_York，固定断言边界的 UTC 时间、春秋周长、同一时刻跨时区归属以及起止包含规则。
这避免修改系统全局时区，也不引入 timezone 依赖；IANA TZ 子进程测试要求 POSIX（Windows 跳过）。

## 大数据与订阅生命周期

统计筛选为 O(N)，周期内 K 项排序为 O(K log K)，各指标遍历周期数据；仍从 DAO 加载全部任务，
内存 O(N)，目前没有数据库分页或索引聚合。2000 项单测验证汇总及过去周期随当前状态变化。
流水使用 SliverList.builder，只构建视口附近行；2000 项 widget 测试从首屏滚到最后一项，
断言最后一项能显示、同时挂载的 Card 少于 50。该测试验证按需布局，不代表真机帧耗时基准。

回顾 provider 使用 autoDispose：页面卸载且无其他消费者时取消数据库流订阅，
保留共享 AppDatabase 生命周期。独立 widget 测试在 ProviderScope 仍存在时卸载页面，
验证订阅取消一次、无剩余监听者，卸载后发出事件不会影响已销毁页面。
