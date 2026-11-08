enum InsightPeriod {
  week('周'),
  month('月');

  const InsightPeriod(this.label);
  final String label;

  /// 先将同一时刻转成本地日历，再构造边界；不能用固定 168 小时跨 DST。
  DateTime start(DateTime instant) {
    final day = DateTime.fromMicrosecondsSinceEpoch(
      instant.microsecondsSinceEpoch,
    );
    return this == week
        ? DateTime(day.year, day.month, day.day - day.weekday + 1)
        : DateTime(day.year, day.month);
  }

  DateTime next(DateTime start, int offset) => this == week
      ? DateTime(start.year, start.month, start.day + 7 * offset)
      : DateTime(start.year, start.month + offset);
}
