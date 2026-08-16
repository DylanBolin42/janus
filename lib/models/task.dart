import 'package:flutter/material.dart';

/// 任务创建表单的临时数据载体
class TaskDraft {
  const TaskDraft({
    this.title = '',
    this.description,
    this.ddl,
    this.est,
    this.priority = 0,
    this.tags = const [],
  });

  final String title;
  final String? description;
  final DateTime? ddl;
  final TimeOfDay? est;
  final int priority;
  final List<String> tags;

  TaskDraft copyWith({
    String? title,
    String? description,
    DateTime? ddl,
    TimeOfDay? est,
    int? priority,
    List<String>? tags,
  }) {
    return TaskDraft(
      title: title ?? this.title,
      description: description ?? this.description,
      ddl: ddl ?? this.ddl,
      est: est ?? this.est,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
    );
  }
}
