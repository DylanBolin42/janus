import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/models/insight_summary.dart';
import 'package:janus/providers/database_provider.dart';
import 'package:janus/shared/custom_appbar.dart';
import 'package:janus/theme/theme.dart';

class InsightPage extends ConsumerStatefulWidget {
  const InsightPage({super.key});

  @override
  ConsumerState<InsightPage> createState() => _InsightPageState();
}

class _InsightPageState extends ConsumerState<InsightPage> {
  InsightPeriod _period = InsightPeriod.week;
  DateTime _anchor = DateTime.now();

  String _date(DateTime date) => '${date.year}/${date.month}/${date.day}';

  Widget _card(
    BuildContext context,
    String title,
    String value,
    String detail,
  ) {
    final theme = Theme.of(context);
    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.contentInterval),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            Text(value, style: theme.textTheme.headlineMedium),
            Text(detail, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final start = _period.start(_anchor);
    final end = _period.next(start, 1);
    final theme = Theme.of(context);
    return CustomAppbar.wrapBody(
      context,
      ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding,
          AppSpacing.contentInterval,
          AppSpacing.pagePadding,
          AppSpacing.bottomSafeArea,
        ),
        children: [
          Wrap(
            spacing: AppSpacing.base,
            children: [
              for (final period in InsightPeriod.values)
                ChoiceChip(
                  label: Text('按${period.label}'),
                  selected: _period == period,
                  onSelected: (_) => setState(() => _period = period),
                ),
              TextButton(
                onPressed: () => setState(() => _anchor = DateTime.now()),
                child: const Text('回到本期'),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                tooltip: '上一${_period.label}',
                onPressed: () =>
                    setState(() => _anchor = _period.next(start, -1)),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  '${_date(start)} — ${_date(DateTime(end.year, end.month, end.day - 1))}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: '下一${_period.label}',
                onPressed: () => setState(() => _anchor = end),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const Text('按截止日期归组，展示任务当前状态；不是历史完成记录。'),
          const SizedBox(height: AppSpacing.contentInterval),
          ref
              .watch(insightTasksProvider)
              .when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Column(
                  children: [
                    const Text('回顾数据加载失败，请重试'),
                    FilledButton.tonal(
                      onPressed: () => ref.invalidate(insightTasksProvider),
                      child: const Text('重试'),
                    ),
                  ],
                ),
                data: (tasks) {
                  final summary = InsightSummary(
                    tasks,
                    start,
                    end,
                    DateTime.now(),
                  );
                  final rate = summary.completionRate;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (summary.tasks.isEmpty) const Text('本期没有到期任务，试试其他周期。'),
                      _card(
                        context,
                        '已完成任务',
                        '${summary.completed}',
                        '本期到期 ${summary.tasks.length} 项，冻结 ${summary.frozen} 项',
                      ),
                      _card(
                        context,
                        '当前完成占比',
                        rate == null ? '—' : '${(rate * 100).round()}%',
                        '已完成 / 非冻结任务；无可统计任务时不计算',
                      ),
                      _card(
                        context,
                        '当前逾期未完成',
                        '${summary.overdue}',
                        '截止时间早于现在，排除已完成及冻结任务',
                      ),
                      _card(
                        context,
                        '预估工作量',
                        '${summary.estimatedMinutes} 分钟',
                        '${summary.estimatedCount} / ${summary.active} 项非冻结任务填写了预估；不是实际专注时长',
                      ),
                      _card(
                        context,
                        '实际专注 / 连续天数',
                        '暂无记录',
                        '尚未保存专注时段和任务完成时间，暂不能计算实际专注时长、连续天数或历史趋势。',
                      ),
                      const SizedBox(height: AppSpacing.contentInterval),
                      Text('任务流水 · 按截止时间', style: theme.textTheme.titleMedium),
                      for (final task in summary.tasks)
                        Card.filled(
                          child: Padding(
                            padding: const EdgeInsets.all(
                              AppSpacing.contentInterval,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  task.title,
                                  style: theme.textTheme.titleMedium,
                                ),
                                Text(
                                  '${_date(task.ddl)} · ${switch (task.status) {
                                    1 => '已完成',
                                    2 => '已规划',
                                    -1 => '已冻结',
                                    0 => '未完成',
                                    _ => '未知状态',
                                  }}',
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
        ],
      ),
    );
  }
}
