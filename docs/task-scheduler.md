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

## 集成门槛：当前仅为算法候选，JANUS-62 尚未完整交付

本 PR 提供可测试的调度核心及集成前置契约。**UI、provider、持久化、权限校验和原子提交均未实现**，不能把“生成了非重叠时间块”表述为自动安排系统已端到端完成。下面是后续接线必须满足的契约；纯 Dart `plan_commit_guard.dart` 只检查提交前置条件，不代替存储事务或鉴权。

### 计划身份、作用域与原子提交

持久化方须为计划保存不可变 envelope：`PlanStamp.schemaVersion`（当前 1）、唯一 `planId`、`userId`、`workspaceId`、`inputRevision`、`scoringVersion`、`schedulingVersion`、UTC `generatedAt` / `validUntil`，以及完整 blocks 和 unscheduled。`generatedAt` 必须等于该次 `ScheduleResult.calculatedAt`，不得在写入时刷新它来延长旧计划寿命。计划身份与输入修订号是存储层提供的不可复用 token，不得用任务 id 或低精度时间戳推导。

`inputRevision` 是该用户/工作区**整个排程快照**的修订号，不只是已安排任务的行版本：包括候选全集、删除记录、窗口、EST 默认值、时区/工作日策略、评分配置 revision、已存在计划版本。只要其中任何内容改变就必须生成新 revision；删除再恢复也不能复用旧 revision。这样即使新增任务尚未出现在旧结果里，也能拒绝旧计划覆盖。

接线顺序必须是：

1. 由可信认证上下文取得 user/workspace，校验工作区成员资格；只读取该作用域的任务、窗口和配置，在一致快照内捕获 revision。任务 id 只在作用域内解释，不能全库按 id 更新。
2. 用同一 now 生成结果并封装 stamp；限制生成后的有效期（由产品策略明确配置，例如最多 5 分钟），同时不得超过最早计划开始时间后仍允许提交的宽限期。过了开始时刻不能未经确认写入已过去的执行块，应重新以当前 now 排程。
3. 写入事务中重新认证/验证作用域、读取当前 revision 与评分/调度版本，调用 `checkPlanCommit`。必须将这个读取、检查、计划替换和 revision 推进放在**同一事务/CAS**中；检查成功后再异步写入仍有 TOCTOU 风险。若 CAS 受影响行数为 0，丢弃本次结果并重新生成，不能强制覆盖。
4. 成功提交须推进 inputRevision，连同 planId 原子落库。两个计划基于同一 revision 生成时，最多一个成功；重放或较晚完成的旧计算因 revision 不匹配被拒绝。撤销/人工编辑计划也推进 revision。禁止跨用户/工作区沿用 stamp。

`checkPlanCommit` 返回 null 只表示传入上下文一致；失败明确区分 scopeMismatch、staleInputs、versionMismatch、notYetValid、expired。调用者传入的“当前上下文”必须从可信事务读取，不能来自客户端自报。辅助函数不自动生成 revision，也不保证数据来自同一快照，不能单独作为并发或租户隔离机制。

### 失效与重新生成规则

任务新增、删除、priority/status/DDL/EST 修改、完成/冻结/恢复、手工移动块、默认时长/窗口/时区/评分配置变化，以及新计划提交，都必须推进作用域 revision，并把旧计划标为失效；恢复旧字段值也仍使用新 revision。失效计划可保留作历史，但不能作为当前有效安排展示或继续写入。调用方也应在 validUntil 到期、跨工作日、恢复应用及当前时间已越过块开始时检查并重排。不要仅靠周期刷新防并发覆盖；不要把删除任务遗留成可执行时间块。专注中的任务不得因后台重排被自动抢占，具体保留策略仍待 UI/会话层实现。

### 固定 Europe/Berlin DST 边界

`test/unit/scheduling/dst_windows_test.dart` 固定了 Europe/Berlin 的 2026 年切换日：

- 春季 2026-03-29：`01:30+01:00` → `03:30+02:00` 实际只有 60 分钟，不能按墙钟差算成 120 分钟。
- 秋季 2026-10-25：第一次 `02:30+02:00` → 第二次 `02:30+01:00` 实际为 60 分钟，不能因为本地显示相同而算成零。

两例验证 60 分钟块刚好装入且 UTC 起止准确，90 分钟任务被拒绝。这些是按命名时区规则预先解析的**固定偏移 fixture**，不声称 Dart `DateTime` 原生支持 IANA 时区，也不测试尚未实现的日历解析器。

后续调用方应保存 IANA zone id（如 Europe/Berlin），通过平台或经过验证的时区库，按每个具体本地日期分别构造工作起止并查当天各自的 UTC offset，再转成绝对 instant 传入 scheduler。不能只记录当前 offset、用机器本地 `DateTime` 代替用户时区，或用前一天 start 加 `Duration(days: 1)` 生成下一天。遇到不存在的本地时刻（春季 gap），必须执行明确的产品策略（拒绝并提示或移至首个有效时刻）；重复时刻（秋季 fold）必须指定第一次/第二次，不能默默猜测。日期型 DDL 的日末转换也遵循同样规则。解析器接线时须再补 named-zone→absolute 的集成测试；本 PR 不新增时区依赖。

### #186 合入后的单一评分服务换接步骤

已只读核对 [#186](https://github.com/DylanBolin42/janus/pull/186) 的 `81fab42` 版本；本分支不依赖、不 cherry-pick 未合并代码。该版本提供 `lib/services/cardo/cardo_scoring_service.dart` 中的 `CardoInput`、`CardoResult`、`CardoScoringService.calculateBatch` / `calculate`。

合入后做一个独立接线变更：

1. 在应用边界捕获唯一配置快照及其 revision，使用 `CardoInput(id, priority, status, deadline, ...)` 构造整批输入；EST 以 `Duration.inMicroseconds / Duration.microsecondsPerMinute` 转为 `estimatedMinutes`，真实缺失值传 null，不能把排程默认时长伪装为用户观测去评分。createdAt、历史效率等只有有真实数据时才传。
2. 将 `_Candidate.score` / `ScheduledBlock.score` 改为共享的 `CardoResult`（或仅封装其值的输出 DTO），删除本地 `CardoScore.calculate` 公式和硬编码等级阈值，不保留第二套公式兜底。用固定同批 now 调用共享服务；需要跨异步边界时显式给每次 `calculate` 传同一个已捕获 config，防止中途配置切换。
3. 用 taskId 将评分结果映射回候选；只有 `eligibility == 'eligible'` 且 score 非空才进入排程。其他 eligibility（包括 blocked/resources unavailable/insufficient_data）映射为明确的未安排理由，不能当零分混入队尾。保留过期排除、无 DDL 调度入选门槛和 EDF 修复，它们是排程规则，不是重复评分。
4. 保留服务返回的未舍入 score、level、contributions、reasons、warnings、`scoringVersion` 和 `configRevision`；`ScheduleResult.scoringVersion` 从静态常量改为配置快照值，stamp 的 inputRevision 同时绑定 configRevision。评分配置一变，旧计划失效。
5. 把当前 Cardo 数值验收测试改成共享服务默认 cardo-v1 配置的契约测试，再补动态阈值/权重、非 eligible、配置 revision 改动失效测试；重跑调度稳定性、冲突/DST 和全套测试。不能把配置变更后的数值仍称为固定 cardo-v1，也不能新增字段却假装已有历史数据。

这样可复用单一评分入口，同时让调度器继续负责时段可行性；具体最终接口以 #186 合入版本为准。

### 可复现性能记录（信息性，不是耗时门槛）

运行 `fvm dart run scripts/benchmark_scheduler.dart`，原始记录提交在 `docs/benchmarks/scheduler-linux-jit.jsonl`。本次环境：Linux x64、2 个逻辑处理器、Dart 3.13.0 JIT；每场景 1 次不计时预热 + 5 次测量，Stopwatch 仅包住 schedule 调用，不含输入生成或 VM 启动。任务固定为 15 分钟、priority 按 id 取模、每五项一项无 DDL；分别测足够大的单窗口和超载的 8 小时单窗口，不使用随机输入。

| 任务数 | 场景 | 安排/未安排 | 中位数 ms | 最大 ms |
| --- | --- | --- | --- | --- |
| 500 | 全部可放入 | 500 / 0 | 14.957 | 16.222 |
| 500 | 8h 超载 | 32 / 468 | 4.221 | 4.403 |
| 2000 | 全部可放入 | 2000 / 0 | 141.702 | 144.445 |
| 2000 | 8h 超载 | 32 / 1968 | 11.512 | 22.908 |

这些数字只是本沙箱该次实测，不代表手机/AOT、碎片窗口或最坏 EDF 反复修复场景的保证。2000 项可装入场景已可能阻塞一帧以上；接线时应在 isolate 中计算，测量目标设备并设置容量/取消策略，不应直接在 UI 帧内同步调用。超载场景更快是因为入选集合最多 32 项，不意味着算法线性扩展。当前无性能断言，避免共享 CI 上的计时抖动造成误报。
