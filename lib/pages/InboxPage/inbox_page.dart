import 'package:drift/drift.dart' show Value;
import 'package:expandable_richtext/expandable_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/database/app_database.dart';
import 'package:janus/providers/database_provider.dart';
import 'package:janus/services/logger_service.dart';
import 'package:janus/theme/theme.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:m3e_dismissible/m3e_dismissible.dart';
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

  /// 滑动手势露出的操作胶囊
  /// [alignment]：右滑色带贴左缘，胶囊贴右缘（挨着卡片）；左滑反之
  Widget _buildSwipeAction({
    required IconData icon,
    required String label,
    required Color stripColor,
    required Color capsuleColor,
    required Color foreground,
    required Alignment alignment,
  }) {
    return Container(
      color: stripColor,
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.base * 2),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.base * 1.5,
          vertical: AppSpacing.base,
        ),
        //decoration: BoxDecoration(
        //  color: capsuleColor,
        //  borderRadius: BorderRadius.circular(999),
        //),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 胶囊宽度随拖拽位移变化：宽度不足时图标等比缩小，避免 RenderFlex 溢出
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(icon, color: foreground, size: 26),
            ),
            SizedBox(height: AppSpacing.base * 0.5),
            Text(
              label,
              // 宽度不足时保持单行、边缘淡出，而不是被拆成竖排（每字一行）
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
              style: TextStyle(
                color: foreground,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 实现任务列表搭建的模块
  Widget _buildTaskList({required List<Task> items}) {
    return M3EDismissibleCardList(
      // 页面整体由外层 ListView 滚动，卡片列表自身不独立滚动。
      // 缺少这两项会导致嵌套 viewport 拿到无界高度，触发
      // 「RenderBox was not laid out … hasSize」断言崩溃。
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final task = items[i];
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${items[i].ddl.month}/${items[i].ddl.day}',
                  style: tt.labelLarge?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
                SizedBox(width: AppSpacing.base),
                Text(
                  '${task.ddl.hour}:${task.ddl.minute.toString().padLeft(2, '0')}',
                  style: tt.labelLarge?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.base),
            Text(
              task.title,
              style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.base),
            if (task.description != null)
              ExpandableRichText(
                task.description!,
                expandText: 'More',
                collapseText: 'Less',
                maxLines: 2,
                style: tt.bodySmall,
              ),
            SizedBox(height: AppSpacing.base * 2),
            // UsedTime 构建（Expanded 等分宽度；勿用 double.infinity，
            // 否则在 shrinkWrap 列表的无界测量约束下会触发
            // 「BoxConstraints forces an infinite width/height」）
            Row(
              children: [
                // EST 构建
                Container(
                  width: 120,
                  height: 60,
                  alignment: AlignmentGeometry.center,

                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(64),
                  ),
                  padding: EdgeInsets.all(AppSpacing.base * 2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_rounded,
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondaryContainer,
                      ),
                      SizedBox(width: AppSpacing.base),
                      Text(
                        task.estHour != null && task.estMinute != null
                            ? '${task.estHour}:${task.estMinute.toString().padLeft(2, '0')}'
                            : '—',
                        style: tt.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
      onDismiss: (i, dir) async {
        var t = items[i];
        if (dir == DismissDirection.endToStart) {
          //TODO: 确认左滑手势的逻辑
          return false;
        }
        if (dir == DismissDirection.startToEnd) {
          // 增量更新：只把 status 置为 1（已完成），其余字段保持数据库原值
          try {
            await ref
                .read(taskDaoProvider)
                .editTask(id: t.id, status: const Value(1));
          } catch (e, stack) {
            AppLogger.e('任务属性：Status变更失败', error: e, stackTrace: stack);
            return false;
          }
          AppLogger.i('任务${t.id}： ${t.title}Status设置为已完成成功');
          return true;
        } else {
          return false;
        }
      },
      style: M3EDismissibleCardStyle(
        outerRadius: 24,
        dismissThreshold: 0.4,
        // 加大周围卡片被拖拽卡片的黏滞拉扯
        neighbourPull: 32.0,
        color: Theme.of(context).colorScheme.surfaceContainer,
        elevation: 0,
        // 左右滑胶囊加大为胶囊形圆角
        backgroundBorderRadius: 128,
        secondaryBackgroundBorderRadius: 128,
        // 右滑 → 完成
        background: _buildSwipeAction(
          icon: Icons.check_rounded,
          label: '完成',
          stripColor: Theme.of(context).colorScheme.primaryContainer,
          capsuleColor: Theme.of(context).colorScheme.primary,
          foreground: Theme.of(context).colorScheme.onPrimaryContainer,
          alignment: Alignment.center,
        ),
        // 左滑 → 更多
        secondaryBackground: _buildSwipeAction(
          icon: Icons.more_horiz_rounded,
          label: '更多',
          stripColor: Theme.of(context).colorScheme.secondaryContainer,
          capsuleColor: Theme.of(context).colorScheme.secondary,
          foreground: Theme.of(context).colorScheme.onSecondaryContainer,
          alignment: Alignment.center,
        ),
      ),
    );
  }

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
                          data: (tasks) => _buildTaskList(items: tasks),
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
