import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/providers/database_provider.dart';
import 'package:janus/shared/task_dismissible_list.dart';
import 'package:janus/theme/theme.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../services/logger_service.dart';

class TimelinePage extends ConsumerStatefulWidget {
  const TimelinePage({super.key});

  @override
  ConsumerState<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends ConsumerState<TimelinePage> {
  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Material(
        child: GlassScaffold(
          topEdgeFade: false,
          body: ListView(
            children: [
              TableCalendar(
                calendarFormat: CalendarFormat.week,
                firstDay: DateTime.utc(2010, 10, 16), //TODO: 需要软编码
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: DateTime.now(),
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Timeline'),
                  Spacer(),
                  GlassIconButton(
                    icon: Icon(Icons.sort_rounded),
                    onPressed: () {
                      //TODO: 添加排序策略选择弹窗
                    },
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.base),
              // 任务卡片显示区域（实时监听数据库，增删改后自动刷新）
              //TODO: 真机验证
              ref
                  .watch(inboxTasksProvider)
                  .when(
                    data: (tasks) => TaskDismissibleList(
                      items: tasks,
                      onDismiss: (task, direction) async {
                        if (direction == DismissDirection.endToStart) {
                          // TODO: 确认左滑手势的逻辑
                          return false;
                        }
                        if (direction == DismissDirection.startToEnd) {
                          // 增量更新：只把 status 置为 1，其余字段保持原值。
                          try {
                            await ref
                                .read(taskDaoProvider)
                                .editTask(id: task.id, status: const Value(1));
                          } catch (e, stack) {
                            AppLogger.e(
                              '任务属性：Status变更失败',
                              error: e,
                              stackTrace: stack,
                            );
                            return false;
                          }
                          AppLogger.i(
                            '任务${task.id}： ${task.title}Status设置为已完成成功',
                          );
                          return true;
                        }
                        return false;
                      },
                    ),
                    loading: () => const M3ELoadingIndicator(),
                    error: (e, st) {
                      AppLogger.e('任务列表加载失败', error: e, stackTrace: st);
                      return const SizedBox(height: 200);
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
