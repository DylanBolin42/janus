import 'package:janus/database/app_database.dart';

enum InsightPeriod {
  week('周'),
  month('月');

  const InsightPeriod(this.label);
  final String label;

  DateTime start(DateTime day) => this == week
      ? DateTime(day.year, day.month, day.day - day.weekday + 1)
      : DateTime(day.year, day.month);

  DateTime next(DateTime start, int offset) => this == week
      ? DateTime(start.year, start.month, start.day + 7 * offset)
      : DateTime(start.year, start.month + offset);
}

/// 截止日期在 [start, end) 内的当前任务快照，不表示历史完成事件。
/// 不缓存聚合值，数据库或周期变化时从同一份任务列表重新计算。
class InsightSummary {
  InsightSummary(List<Task> source, this.start, this.end, this.now)
    : tasks = List.unmodifiable(
        source
            .where((t) => !t.ddl.isBefore(start) && t.ddl.isBefore(end))
            .toList()
          ..sort((a, b) {
            final byDate = a.ddl.compareTo(b.ddl);
            return byDate == 0 ? a.id.compareTo(b.id) : byDate;
          }),
      );

  final DateTime start;
  final DateTime end;
  final DateTime now;
  final List<Task> tasks;

  int get completed => tasks.where((t) => t.status == 1).length;
  int get frozen => tasks.where((t) => t.status == -1).length;
  int get active => tasks.length - frozen;
  double? get completionRate => active == 0 ? null : completed / active;
  int get overdue => tasks
      .where((t) => t.status != 1 && t.status != -1 && t.ddl.isBefore(now))
      .length;
  int get estimatedMinutes => tasks
      .where((t) => t.status != -1)
      .fold(0, (sum, t) => sum + (t.estHour ?? 0) * 60 + (t.estMinute ?? 0));
  int get estimatedCount => tasks
      .where(
        (t) => t.status != -1 && (t.estHour != null || t.estMinute != null),
      )
      .length;

  // TODO(JANUS-63): 在 task_tables.dart 增加 completedAt，并在 TaskDao.editTask
  // 的完成/撤销操作中维护它；如需历史达成率需增加状态事件或每日快照。
  // 之后才能按实际完成日统计完成数、连续完成天数和历史趋势。
  // TODO(JANUS-63): FocusPage 需先实现并持久化专注时段表（taskId、startedAt、
  // endedAt、有效专注秒数、取消状态），在 AppDatabase 接入迁移与 DAO，
  // 再按周期边界裁剪时段计算实际专注时长与连续专注天数，不能用 EST 替代。
}
