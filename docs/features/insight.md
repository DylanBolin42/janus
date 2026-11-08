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
