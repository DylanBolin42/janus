import 'package:flutter/material.dart';
import 'package:janus/models/task.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_draft_provider.g.dart';

@riverpod
class TaskDraftNotifier extends _$TaskDraftNotifier {
  @override
  TaskDraft build() {
    // 表单草稿无人 watch（只有 ref.read），默认 autoDispose 会在空闲时被销毁
    // 导致输入中途丢失、提交时读到空草稿。keepAlive 让草稿在整个 App 生命周期存活。
    ref.keepAlive();
    return const TaskDraft();
  }

  void reset() => state = const TaskDraft();

  void setTitle(String v) => state = state.copyWith(title: v);
  void setDescription(String v) => state = state.copyWith(description: v);
  void setDdl(DateTime v) => state = state.copyWith(ddl: v);
  void setEst(TimeOfDay v) => state = state.copyWith(est: v);
  void setPriority(int v) => state = state.copyWith(priority: v);
  void setTags(List<String> v) => state = state.copyWith(tags: v);
}
