import 'package:flutter/material.dart';

/// 任务模型 —— 首页三种模式（紧急 / 计划 / 即将到来）的任务数据载体。
///
/// 目前由 mock 数据填充，后续将替换为数据库（drift）真实查询。
class Task {
  const Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.priority = '中',
    required this.ddl,
    required this.est,
  });

  /// 唯一标识
  final String id;

  /// 任务标题
  final String title;

  /// 任务描述（可空，紧凑卡片下不展示）
  final String? description;

  /// 是否已完成
  final bool isCompleted;

  /// 优先级（'紧急' | '高' | '中' | '低'），与 [TaskCard] 的解析逻辑对应
  final String priority;

  /// 截止时间
  final DateTime ddl;

  /// 预计耗时
  final TimeOfDay est;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    String? priority,
    DateTime? ddl,
    TimeOfDay? est,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      ddl: ddl ?? this.ddl,
      est: est ?? this.est,
    );
  }
}
