import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/models/task.dart';
import 'package:janus/pages/Inbox/inbox_mock_data.dart';
import 'package:janus/shared/task_card.dart';
import 'package:janus/theme/theme.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:reel_text/reel_text.dart';

/// 首页轮播的三种模式（有序循环）
const List<String> _inboxModes = ['EMERGENCY', 'PLANNED', 'COMING'];

/// 当前模式索引（Riverpod 状态）
final _currentModeIndexProvider = StateProvider<int>((ref) => 0);

/// 任务列表数据提供者（Riverpod 状态），使用 mock 数据进行初始化
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

                  // 任务卡片显示区域：使用独立的 ConsumerWidget 进行渲染以优化重绘性能
                  const _InboxTaskList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 独立的任务列表组件，避免重绘上方的静态头部，实现高昂计算及重绘精细隔离。
class _InboxTaskList extends ConsumerWidget {
  const _InboxTaskList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modeIndex = ref.watch(_currentModeIndexProvider);
    final currentMode = _inboxModes[modeIndex];
    final tasksMap = ref.watch(_inboxTasksProvider);
    final tasks = tasksMap[currentMode] ?? [];

    // 高效渲染：由于被嵌套在 parent ListView 中，必须开启 shrinkWrap 并禁用滚动，确保约束正确传递
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.base),
          child: TaskCard(
            key: ValueKey(task.id),
            title: task.title,
            description: task.description,
            isCompleted: task.isCompleted,
            priority: task.priority,
            ddl: task.ddl,
            est: task.est,
            onToggle: (completed) {
              ref.read(_inboxTasksProvider.notifier).update((state) {
                final updatedList = List<Task>.from(state[currentMode]!);
                updatedList[index] = task.copyWith(isCompleted: completed);
                return {...state, currentMode: updatedList};
              });
            },
          ),
        );
      },
    );
  }
}
