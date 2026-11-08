# JANUS-62：任务自动安排 API

入口：`lib/scheduling/task_scheduler.dart`。纯 Dart、同步确定性函数；未接线 UI、provider 或数据库，不修改任务状态。无新增依赖。

## 依据

先全文提取阅读《任务优先级个性化评定与动态调整研究》（内文标题《个性化任务优先级管理的多学科理论整合与算法机制研究报告》）与《janus工程文档》。前者 §1.2、§5.1.2 的 EDF 和可行性检查指导截止约束修复，§1.1 的多属性决策区分重要性与紧迫性；后者 §2.1 的 Prospect 时间盒与 Cardo 评分指导分层。这里没有周期、WCET、可抢占保证，不套用实时系统利用率定理，也不声称可保证真实任务按时完成。

评分严格实现 [JANUS-26 文档（PR #181，a38551e）](https://github.com/DylanBolin42/janus/blob/a38551ec89a85437aac4f047368694d286023007/docs/priority-algorithm.md) 的 `cardo-v1`，不新增耗时、历史效率、依赖等评分因子。开发时 #181 仍 OPEN，main 尚无该文档，故引用固定版本而不复制或更改其内容；合入后对应 `docs/priority-algorithm.md`。

`S = 100 × (0.625 × priority/3 + 0.375 × U)`，有 DDL 时 `U=1/(1+max(剩余精确小时,0)/24)`，无 DDL 时 `U=0`。不舍入排序；A ≥70，B ≥40，C <40。输出保留两项贡献及版本。JANUS-62 额外规定无 DDL 候选低于有 DDL 候选，这是**调度入选规则**，不改变 Cardo 分数；同组按分数降序、DDL 升序、id 升序。

## 输入与输出

- `SchedulingTask`：唯一整数 id、priority 0–3、status（0 未完成、2 已规划可参与；1 完成、-1 冻结排除）、可空 deadline 和可空 `Duration estimatedDuration`。未知 status、非法 priority、非正 EST 返回 `invalidInput`。
- `now`：同批时钟快照；统一为 UTC 瞬时。DDL ≤ now 不参与，返回 `expired`（包含截止瞬间，因为正时长任务已不可能准时完成）。完成、冻结、逾期项无分数。
- `windows`：绝对半开区间 `[start,end)`，调用者可提供今天剩余或未来多日工作时段；裁去 now 之前部分、忽略已结束时段、合并重叠及相邻区间。反向/零长窗口抛 `ArgumentError`。本地日历/时区和夏令时由调用边界解析；输出 UTC，不用 `Duration(days: 1)` 猜本地工作日。
- 缺 EST 使用 `SchedulerConfig.defaultDuration`（默认 30 分钟），输出 `usesDefaultDuration` 及理由。所有输出的 `durationIsEstimated=true`，已有 EST 也不是实际耗时。配置必须为正。
- `unavailablePeriods` 只预留给 JANUS-30；空列表可用，非空抛 `UnsupportedError`，不会静默忽略。未实现休息识别、插入或区间扣除。当前调用者仅传已确认可工作的 windows。
- `ScheduleResult.blocks` 按开始时间升序，每块含 taskId、start/end、时长来源、未舍入 Cardo 分数/等级/贡献及 `SchedulingReason`。无 DDL、未设重要性、默认耗时均有理由。
- `unscheduled` 按 id 排列，每条含原因和可用时的分数。重复 id 抛 `ArgumentError`，避免同一任务被安排两次。输出列表不可变，输入不被修改；不使用随机数或系统时钟。

现有 Drift Task 的 `ddl` 非空，API 支持草稿/外部输入无 DDL；接线时用 `Duration(hours: estHour, minutes: estMinute)` 映射有效 EST，任一字段缺失应传 null，不把 `TimeOfDay` 当执行时刻。未改数据库 schema。

```dart
final now = DateTime.utc(2026, 11, 8, 9);
final result = const TaskScheduler().schedule(
  now: now,
  windows: [SchedulingWindow(now, DateTime.utc(2026, 11, 8, 12))],
  tasks: [
    SchedulingTask(id: 1, priority: 3,
      deadline: DateTime.utc(2026, 11, 9),
      estimatedDuration: Duration(hours: 1)),
    SchedulingTask(id: 2, priority: 0,
      deadline: DateTime.utc(2026, 11, 8, 9, 30)),
  ],
);
// 2: 09:00–09:30（默认估计），1: 09:30–10:30；两块标记 deadlineRepair。
```

## 调度与取舍

1. 校验、排除，再计算固定 now 下的 Cardo 分数，形成入选顺序。
2. 每个候选先单独试排。即使独占窗口也无连续时段：`insufficientWindow`；有连续时段但 DDL 前放不下：`deadlineUnreachable`。DDL 在窗口结束以后仍可在窗口内提前做完，不直接拒绝。
3. 每次尝试加入候选，对已入选集合重新按入选顺序 earliest-fit 装入空闲段，每任务保持连续、不拆分。只接受 end ≤ DDL 的块。较长任务跳到后面的窗口时，较短任务可以回填前面的空档。
4. 分数顺序失败则对整个试排集合改用 EDF（DDL 升序、同 DDL 用原排名）重排。成功则允许紧迫低分任务插队，并在最终使用 EDF 的计划所有块上标记 `deadlineRepair`：它表示**全局采用截止修复顺序**，包括因此推迟的高分任务，不表示每项都前移。无 DDL 放在 EDF 队尾。
5. 两种顺序均失败，保留已入选的较高排名任务，新候选返回 `lowerPriorityConflict` 和 `conflictingTaskIds`（保留集合，不声称是最小冲突集合）。拒绝不会丢失上一版修复计划；后续更短候选仍可尝试。

例：远期高分需 60 分钟，临期低分需 30 分钟且 30 分钟后截止，90 分钟窗口可以 EDF 修复为低分→高分；若窗口仅 60 分钟，两者无法兼得，保留远期高分，明确报告临期低分冲突。此规则保护重要工作，并显式承认超载时会牺牲较低排名的截止需求。

这是非抢占式启发式：工作时段分散时，两种贪心顺序可能错过其他可行排列；不声称全局最优、最大任务数或总价值最大化。`insufficientWindow` 包含碎片导致连续时间不足，`lowerPriorityConflict` 表示本策略未找到联合计划，并非数学不可行证明。n 任务、w 窗口最坏时间 O(n²(w + log n))，不做指数搜索。

## 验证与后续

单测覆盖 JANUS-26 数值、阈值、亚秒精度、稳定顺序、EDF 插队、保留长程重要工作、超载取舍、无 DDL、缺 EST、状态过滤、窗口归一化/跨日/空档、连续性、越界、非法输入及固定种子密集堆积不变量。

TODO：UI/provider/持久化入口；JANUS-30 不可用时段处理；接线后的 EST 校验与时区输入规范；按实际反馈评估碎片窗口的更强可行性搜索。不实现依赖、实际耗时学习、创建时间老化、自动执行、后台周期重排。

## PR #184 交付验证记录

实现提交：`af92d38e3e9f5a834ad90f54d65a56ca9d21e307`，分支 `dylanbolin09/janus-62-auto-scheduler`，沿用 [PR #184](https://github.com/DylanBolin42/janus/pull/184)。

- Flutter 3.47.0 / Dart 3.13.0；`fvm flutter test --no-pub --concurrency=4`：228 项全部通过，新增调度测试 23 项，其中密集队列用固定种子检查 30 批输入。
- `fvm flutter analyze --no-pub`：4 info + 2 warning，与独立 main `d5f33fa` 的 6 条诊断逐条一致，无新增诊断；退出码为 1，不是零诊断通过。
- `dart analyze lib/scheduling test/unit/scheduling`：No issues found。
- `fvm dart format --output=none --set-exit-if-changed lib/scheduling test/unit/scheduling`：0 changed；`git diff --check` 通过。
- GitHub [CI 42441162686](https://github.com/DylanBolin42/janus/actions/runs/42441162686)：Format & Analyze、Tests & Coverage、Build Android Check、PR Summary 全部通过。
- GitHub [Dependency Check 42441162669](https://github.com/DylanBolin42/janus/actions/runs/42441162669)：通过；CodeQL 亦通过。PR 未合并，auto-merge 关闭。

可复跑入口：在仓库根目录执行 `bash scripts/verify_scheduler.sh`。需要已配置 FVM/Flutter；脚本运行全套测试，并用分支与 `origin/main` 的 merge-base 建立临时工作树对照分析诊断。运行日志写入忽略目录 `.dart_tool/scheduler-verification/`，结束后移除临时工作树。完整原始输出是可重建验证产物，不提交；此节保存验收结果与远程 CI 证据。

交接附件 `uploads/` 下两份 PDF 是用户提供的参考原件，不属于源码变更，不复制进公共仓库；材料来源与采用规则已在前文说明。Flutter SDK、包缓存、build、临时 PDF 提取文本、原始测试日志及旧的一次性后台编排脚本均为临时环境产物。
