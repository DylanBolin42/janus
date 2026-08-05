import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/theme/theme.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:m3e_dismissible/m3e_dismissible.dart';
import 'package:reel_text/reel_text.dart';
import 'package:janus/models/task.dart';
import 'package:janus/shared/task_card.dart';
import 'package:janus/pages/Inbox/inbox_mock_data.dart';

/// 首页轮播的三种模式（有序循环）
const List<String> _inboxModes = ['EMERGENCY', 'PLANNED', 'COMING'];

/// 当前模式索引（Riverpod 状态）
final _currentModeIndexProvider = StateProvider<int>((ref) => 0);

/// 任务列表数据提供者（包含每种模式的任务列表）
final _inboxTasksProvider = StateProvider<Map<String, List<Task>>>((ref) {
  return buildInboxMockData();
});

class InboxPage extends ConsumerStatefulWidget {
  const InboxPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InboxPageState();
}

class _InboxPageState extends ConsumerState<InboxPage> {
  /// reel_text 控制器：驱动模式标签的滚动动画
  late final ReelTextController _modeController;

  // final 常量定义
  double get screenWidth => MediaQuery.sizeOf(context).width;
  TextTheme get tt => Theme.of(context).textTheme;

  @override
  void initState() {
    super.initState();
    _modeController = ReelTextController(
      initialText: _inboxModes[ref.read(_currentModeIndexProvider)],
    );
  }

  @override
  void dispose() {
    _modeController.dispose();
    super.dispose();
  }

  /// 循环切换模式：delta = 1 下一个，-1 上一个
  void _cycleMode(int delta) {
    final total = _inboxModes.length;
    ref.read(_currentModeIndexProvider.notifier).update((index) {
      return (index + delta + total) % total;
    });
  }

  /// 实现任务列表搭建的模块
  Widget _buildTaskList({required List<Task> items, required String mode}) {
    return M3EDismissibleCardList(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final task = items[i];
        return TaskCard(
          key: ValueKey(task.id),
          title: task.title,
          description: task.description,
          isCompleted: task.isCompleted,
          priority: task.priority,
          ddl: task.ddl,
          est: task.est,
          onToggle: (completed) {
            ref.read(_inboxTasksProvider.notifier).update((state) {
              final currentModeTasks = state[mode] ?? [];
              final updatedList = currentModeTasks.map((t) {
                if (t.id == task.id) {
                  return t.copyWith(isCompleted: completed);
                }
                return t;
              }).toList();
              return {...state, mode: updatedList};
            });
          },
        );
      },
      onDismiss: (i, dir) async {
        ref.read(_inboxTasksProvider.notifier).update((state) {
          final currentModeTasks = state[mode] ?? [];
          final updatedList = List<Task>.from(currentModeTasks)..removeAt(i);
          return {...state, mode: updatedList};
        });
        return true;
      },
      style: M3EDismissibleCardStyle(
        outerRadius: 24,
        dismissThreshold: 0.3,
        neighbourPull: 12.0,
        color: Theme.of(context).colorScheme.surfaceContainer,
        elevation: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Riverpod 状态 → reel_text：切换时触发滚动动画
    ref.listen(_currentModeIndexProvider, (previous, next) {
      final total = _inboxModes.length;
      final delta = ((next - (previous ?? 0)) % total + total) % total;
      _modeController.set(
        _inboxModes[next],
        // 前进默认向下滚；后退向上滚
        options: delta == 1
            ? null
            : const ReelTextOptions(direction: ReelTextDirection.up),
      );
    });
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: GlassScaffold(
        topEdgeFade: false,
        body: ListView(
          children: [
            Container(
              width: screenWidth,
              height: 300,
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
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1),
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

                  // 任务显示切换器
                  Container(
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(128),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: AppSpacing.base),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.secondaryContainer,
                            shape: CircleBorder(),
                          ),
                          onPressed: () => _cycleMode(-1),
                          tooltip: '上一个模式',
                          icon: Icon(Icons.keyboard_arrow_left_rounded),
                          iconSize: 70,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                        ),
                        SizedBox(width: AppSpacing.base),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(128),
                            ),
                            height: 80,

                            child: ReelText.controller(
                              controller: _modeController,
                              style: TextStyle(
                                fontFamily: 'AntonTitle',
                                fontSize: 30,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.base),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.secondaryContainer,
                            shape: CircleBorder(),
                          ),
                          onPressed: () => _cycleMode(1),
                          tooltip: '下一个模式',
                          icon: Icon(Icons.keyboard_arrow_right_rounded),
                          iconSize: 70,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                        ),
                        SizedBox(width: AppSpacing.base),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.base),

                  // 任务卡片显示区域
                  Builder(
                    builder: (context) {
                      final modeIndex = ref.watch(_currentModeIndexProvider);
                      final mode = _inboxModes[modeIndex];
                      final allTasks = ref.watch(_inboxTasksProvider);
                      final tasks = allTasks[mode] ?? [];

                      if (tasks.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.all_inclusive_rounded,
                                size: 48,
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '所有任务已搞定，太棒了！',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                              ),
                            ],
                          ),
                        );
                      }

                      return _buildTaskList(items: tasks, mode: mode);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
