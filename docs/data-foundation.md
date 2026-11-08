# JANUS-63：Cardo 数据底座与唯一评分入口

本实现以 [priority-algorithm.md](priority-algorithm.md)（#181，8125708）为基线。
`CardoScoringService.calculate` / `calculateBatch` 是唯一公式入口；调用方传入
`CardoInput`、同批 `now` 和可注入的 `CardoConfigService`。输出 `score`、`level`、
`scoringVersion`、`configRevision`、贡献、原因和警告。批次按未舍入分数、DDL、id 排序。
不把算法等级写回手动 priority，不自动执行或抢占专注任务。

## Schema v4 与升级

- `tasks.createdAt/startedAt/completedAt` 可空。新建记录 UTC 创建瞬时；首次 `start`
  设置 startedAt；完成设置 completedAt，撤销完成清空 completedAt，但事件留存。
  SQLite 沿用 Drift 的 epoch 秒存储，读出可能是本地 DateTime；计算统一转 UTC。
- **`usedTime` 是实际累计有效整分钟**，数据库列 `used_time`，可空且非负。
  EST 的单位固定为 `estHour * 60 + estMinute` **分钟**：hour 是时长小时，minute
  是 0–59 的余数，绝不是钟表时刻。现有 TimeOfDay 表单只能录入 0–23 小时，
  数据层可读取更长的非负小时；非法/不完整 EST 视为未知。
- `CardoDataService.addUsedTime(id, minutes)` 每次显式提交正整数分钟，事务内累加
  usedTime 并写 `time_logged` 事件和当时 EST。首次观测前为 null；完成操作**不**把
  EST 或 startedAt 到当前的墙钟时间当作实际投入。完成/撤销不清零 usedTime。
  选择累计加事件方案：支持人工或专注模块提交有效分钟，不必先实现完整计时器，
  同时保留审计与估计快照。调用方须对同一观测只提交一次；API 非幂等。
- `priorityExplicit` 可空：编辑 priority 时设 true。历史及新建默认 0 不猜测是否显式选择。
- `task_dependencies(predecessor, successor)` 联合主键，前置→后续；外键级联删除。
  事务内校验任务存在及可达性，拒绝自环/间接环；CRUD 用 CardoDataService。
- `task_events` 保存 started/time_logged/completed/reopened/failed，以及
  priority_changed/exposed/accepted/ignored。时间、实际分钟、当时预计分钟、改档值、
  失败原因、反馈配置修订号按事件种类可空。complete 重试不重复计成功；撤销事件
  不抹去曾经完成的事实。失败仅表示显式记录的执行尝试，不从冻结或撤销推断失败。
- `task_contexts` 每任务一条可选资源就绪、可用分钟、精力匹配和目标影响（0–1），
  必须给 expiresAt，过期即未知。此处是显式用户输入接口，绝不从 tags/标题推断。
- 升级 v1→v4、v2→v4、v3→v4 保留原有列，按版本补 tags/status，再补上述列/表。
  **所有旧任务新列均留 null、事件/依赖/情境表为空**；不从 id、DDL、EST 或完成状态
  回填创建/完成/实际时间。迁移测试从真实旧 SQLite 表定义及 user_version 打开。
  新库直接 createAll，连接开启 foreign_keys，覆盖约束与级联清理。

## 默认兼容与扩展因子

`version:1` 完全遵守原 §7：只支持 base/urgency，EST 显式启用报 unsupported_factor。
默认 62.5/37.5、24h、40/70 不变，固定例分别 92.5、51.041666…、37.5、62.5、null。

原文 §6 只有若干候选公式，未定义效率/依赖/反馈的完整数值模型；因此不静默改变
cardo-v1，而注册**显式选择的 `version:2` / `scoringVersion:cardo-v2`**。采用原文
`100 × Σ(w×f)` 框架。v2 默认仍仅启用 base/urgency，其余全部 false/0；这些扩展
是可检验的工程初值，不声称已经过个性化校准。阈值仍显式可配，启用扩展时必须评估。

| 因子 | 已实现公式及真实输入 | 空数据的降级 |
| --- | --- | --- |
| base | §3 priority_values 查表 | priority=0 警告；非法 priority 拒算 |
| urgency | §3 `1/(1+max(h,0)/H)` | 缺 DDL 固定0且保留权重，与 v1 一致 |
| aging | §6 `min(age_days/scale_days,1)`，默认30天 | 无 createdAt 移除该权重 |
| decay | §6 `exp(-lambda_per_day*age_days)`，默认 λ=.01 | 无 createdAt 移除该权重；与老化方向相反，需调用方按任务类型选用 |
| estimated_duration | §6 `1/(estimated_minutes/scale_minutes+1)`，默认60分钟 | 不使用 default_minutes 伪造观测；无有效 EST 移除权重 |
| dependency | 前置未完成先排除；解锁收益 `L/(L+scale_minutes)`，默认60分钟；L 为最长下游路径剩余预计分钟和 | 无下游为真实0；路径任一 EST 未知则该因子未知，不假装关键路径完整 |
| efficiency | 有完成样本时，平均 `min(estimated_at_completion/used_at_completion,1)`；无完成样本时使用当前显式 EST/usedTime 的同一有界比值 | 无有效正分钟观测则移除；当前比值仅耗时效率代理，非生产率测量 |
| success | §6 `(successes+1)/(attempts+2)`；同任务 completed+failed 为分母 | 零尝试未知，不以先验冒充观测 |
| context | 未过期的 energyMatch，资源就绪 false / 可用分钟不足是前置门槛 | 无/过期精力匹配移除权重；未知资源不声称就绪 |
| goal | 未过期的显式 goalImpact | 无目标影响输入移除权重，不从文本推断 |
| feedback | `(accepted+1)/(accepted+ignored+priority_changed+2)`，同任务显式结果事件 | 无反馈移除；曝光仅记录，不把未回应的曝光视为拒绝 |

v2 可选因子缺数据时发 `missing_data:<factor>:weight_removed` 并对其余有效权重重新
归一化；零有效权重返回 insufficient_data，score/level=null。这样全空扩展不改变 v1。
不改变 v1 的“缺 DDL 保留权重”规则。完成/冻结、依赖未完成、已知资源不可用门槛
先处理，不能通过配置旁路。被排除任务与无数据任务均不是零分候选。

历史效率当前按全部真实完成样本聚合，尚无任务类型校准、分时段效率、传感器精力
推断或自动学习权重。专注模块可以通过 addUsedTime 接入；本 PR 不新增计时器、
日历采集器或自动训练系统。事件重开后保留旧尝试，成功率衡量的是执行尝试而非最终净状态。

## 配置与应用入口

v1 完整 schema 仍见原文 §7；v2 完整 schema 见 [cardo-config-v2.schema.json](cardo-config-v2.schema.json)。
所有新增因子沿用 `{enabled,weight,normalization,params}` 形状；默认关闭且权重0。
归一化参数上界：scale_days [1,36500]、lambda_per_day [0,1]、scale_minutes [1,10080]。
其余新增 normalization/params 为空对象；未知键警告并剔除。原权重 [0,10]，有效和≥1e-6。
示例（缺字段逐项从内置默认回退）：

```json
{"version":2,"factors":{"aging":{"enabled":true,"weight":0.1},"dependency":{"enabled":true,"weight":0.2},"efficiency":{"enabled":true,"weight":0.1}}}
```

加载器限制64KiB、深度16，严格 UTF-8 JSON，拒绝重复/转义后重复键、非有限值、
错误类型、错误版本和跨字段冲突。已知字段 null 不视为缺失。每次成功完整替换不可变
快照，修订递增；错误保留旧快照，文件缺失恢复内置 v1。每批捕获一个 config/now。
`diagnostics` 提供只读生效快照、有效权重和独立的最近尝试状态。
设置→规划→优先级算法→当前配置可指定路径、重载并查看诊断；路径用本地设置保存。
启动建立默认后加载指定路径；轮询每2秒检查，支持原子重命名/删除，读操作串行，JSON 解析与校验在独立 isolate 执行；过期请求不能覆盖较新发布。
源文件不执行脚本、不 include、不读取其指定的其他路径。推荐同目录临时文件原子替换。

`cardoConfigProvider` / `cardoScoringProvider` / `cardoDataProvider` / `cardoResultsProvider`
是复用接入点。结果流监听四张表、配置替换及每60秒时钟；一次提交后重算整图，
同时覆盖下游候选资格和上游解锁收益。旧修订结果不发布。现有 Inbox 展示顺序保持由
原任务流控制，调用方可消费独立 cardoResultsProvider；本 PR 不擅自替换展示策略。
**#184 后续只需把本地 CardoScore 换成 CardoScoringService，消费结果与版本，不复制公式。**
#185 也修改 database_provider.dart，合并时需处理 provider 相邻改动。
