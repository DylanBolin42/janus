import 'package:flutter/material.dart';
import 'package:janus/database/app_database.dart';

extension TaskX on Task {
  TimeOfDay? get est {
    final h = estHour;
    final m = estMinute;
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }
}
