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
    this.id,
    this.status = 0, // 0-未完成，1-已完成；与数据库默认值一致
  });

  final int? id; // 修改时专用标识，创建时不传参
  final int status;
  final String title;
  final String? description;
  final DateTime? ddl;
  final TimeOfDay? est;
  final int priority;
  final List<String> tags;

  TaskDraft copyWith({
    int? id,
    int? status,
    String? title,
    String? description,
    DateTime? ddl,
    TimeOfDay? est,
    int? priority,
    List<String>? tags,
  }) {
    return TaskDraft(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      ddl: ddl ?? this.ddl,
      est: est ?? this.est,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      status: status ?? this.status,
    );
  }
}
