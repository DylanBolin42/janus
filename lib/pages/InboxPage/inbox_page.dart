import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/providers/database_provider.dart';
import 'package:janus/services/logger_service.dart';
import 'package:janus/shared/task_dismissible_list.dart';
import 'package:janus/theme/theme.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

/// 首页任务的三种显示模式。
const List<String> _inboxModes = ['Critical', 'Planned', 'Coming'];

/// 当前模式索引（Riverpod 状态）
class _CurrentModeIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) {
    state = index;
  }
}

final _currentModeIndexProvider =
    NotifierProvider<_CurrentModeIndexNotifier, int>(
      _CurrentModeIndexNotifier.new,
    );

class InboxPage extends ConsumerStatefulWidget {
  const InboxPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InboxPageState();
}

class _InboxPageState extends ConsumerState<InboxPage> {
  // final 常量定义
  double get screenWidth => MediaQuery.sizeOf(context).width;
  TextTheme get tt => Theme.of(context).textTheme;

  @override
  Widget build(BuildContext context) {
    final selectedModeIndex = ref.watch(_currentModeIndexProvider);
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Material(
        child: GlassScaffold(
          topEdgeFade: false,
          body: ListView(
            children: [
              Container(
                width: screenWidth,
                height: 250,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(AppRadius.xl),
                  ),
                ),
                padding: EdgeInsets.only(
                  left: AppSpacing.base,
                  bottom: AppSpacing.base,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GOOD MORNING',
                      style: TextStyle(
                        fontFamily: 'AntonTitle',
                        fontSize: 70,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: AppSpacing.base),
                    Text(
                      'BRO', //TODO: 改为真实用户名
                      style: TextStyle(
                        fontFamily: 'AntonTitle',
                        fontSize: 80,
                        height: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.base),
              Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: AppSpacing.pagePadding,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text.rich(
                          textAlign: TextAlign.start,
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'TIME LEFT ',
                                style: tt.bodyLarge?.copyWith(
                                  fontFamily: 'AntonTitle',
                                ),
                              ),
                              TextSpan(
                                text: '2H45M',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ), //TODO: 添加背景装饰和字体，以及接入真实逻辑
                            ],
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                    LinearProgressBar(
                      maxSteps: 6,
                      progressType: ProgressType.linear,
                      currentStep: 3,
                      progressColor: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(context).colorScheme.onSurface
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(64),
                      minHeight: 12,
                    ),
                    Row(
                      children: [
                        Spacer(),
                        Text.rich(
                          textAlign: TextAlign.end,
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'EST LEFT ',
                                style: tt.bodyLarge?.copyWith(
                                  fontFamily: 'AntonTitle',
                                ),
                              ),
                              TextSpan(
                                text: '2H34M',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ), //TODO: 添加背景装饰和字体
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.base),

                    // 任务显示切换器（M3E ButtonGroup）
                    SizedBox(
                      width: double.infinity,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // connected 组在按钮间保留 2dp 缝隙。
                          final actionWidth =
                              (constraints.maxWidth - 4) / _inboxModes.length;
                          return M3EButtonGroup(
                            type: M3EButtonGroupType.connected,
                            shape: M3EButtonShape.round,
                            size: M3EButtonSize.md,
                            style: M3EButtonStyle.filled,
                            density: M3EButtonGroupDensity.regular,
                            neighborSquish: true,
                            multiSelect: false,
                            selectionRequired: true,
                            selectedIndex: selectedModeIndex,
                            onSelectedIndexChanged: (int? index) {
                              if (index != null) {
                                ref
                                    .read(_currentModeIndexProvider.notifier)
                                    .select(index);
                              }
                            },
                            actions: [
                              for (final mode in _inboxModes)
                                M3EButtonGroupAction(
                                  width: actionWidth,
                                  label: Text(
                                    mode,
                                    style: const TextStyle(
                                      fontFamily: 'AntonTitle',
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: AppSpacing.base),

                    // 任务卡片显示区域（实时监听数据库，增删改后自动刷新）
                    //TODO: 根据优先级计算选择性传参
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
                                      .editTask(
                                        id: task.id,
                                        status: const Value(1),
                                      );
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
                    SizedBox(height: AppSpacing.bottomSafeArea),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
