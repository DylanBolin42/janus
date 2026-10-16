import 'package:expandable_richtext/expandable_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:janus/database/app_database.dart';
import 'package:janus/theme/theme.dart';
import 'package:m3e_dismissible/m3e_dismissible.dart';

/// 可复用的可滑动任务卡片列表。
///
/// 列表只负责任务展示和滑动交互；完成任务等业务操作由 [onDismiss] 决定。
class TaskDismissibleList extends StatelessWidget {
  const TaskDismissibleList({
    required this.items,
    required this.onDismiss,
    super.key,
  });

  final List<Task> items;
  final Future<bool> Function(Task task, DismissDirection direction) onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return M3EDismissibleCardList(
      // 由外层滚动视图承载滚动，避免嵌套 viewport 的无界高度问题。
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final task = items[index];
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${task.ddl.month}/${task.ddl.day}',
                  style: textTheme.labelLarge?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                SizedBox(width: AppSpacing.base),
                Text(
                  '${task.ddl.hour}:${task.ddl.minute.toString().padLeft(2, '0')}',
                  style: textTheme.labelLarge?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.base),
            Text(
              task.title,
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.base),
            if (task.description != null)
              ExpandableRichText(
                task.description!,
                expandText: 'More',
                collapseText: 'Less',
                maxLines: 2,
                style: textTheme.bodySmall,
              ),
            SizedBox(height: AppSpacing.base * 2),
            // shrinkWrap 列表中使用固定尺寸，避免无界约束下的无限尺寸。
            Row(
              children: [
                Container(
                  width: 120,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(64),
                  ),
                  padding: EdgeInsets.all(AppSpacing.base * 2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_rounded,
                        color: colorScheme.onSecondaryContainer,
                      ),
                      SizedBox(width: AppSpacing.base),
                      Text(
                        task.estHour != null && task.estMinute != null
                            ? '${task.estHour}:${task.estMinute.toString().padLeft(2, '0')}'
                            : '—',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: colorScheme.onSecondaryContainer,
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
      onDismiss: (index, direction) => onDismiss(items[index], direction),
      style: M3EDismissibleCardStyle(
        outerRadius: 24,
        dismissThreshold: 0.4,
        neighbourPull: 32,
        color: colorScheme.surfaceContainer,
        elevation: 0,
        backgroundBorderRadius: 128,
        secondaryBackgroundBorderRadius: 128,
        background: _TaskSwipeAction(
          icon: Icons.check_rounded,
          label: '完成',
          stripColor: colorScheme.primaryContainer,
          foreground: colorScheme.onPrimaryContainer,
          alignment: Alignment.center,
        ),
        secondaryBackground: _TaskSwipeAction(
          icon: Icons.more_horiz_rounded,
          label: '更多',
          stripColor: colorScheme.secondaryContainer,
          foreground: colorScheme.onSecondaryContainer,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}

class _TaskSwipeAction extends StatelessWidget {
  const _TaskSwipeAction({
    required this.icon,
    required this.label,
    required this.stripColor,
    required this.foreground,
    required this.alignment,
  });

  final IconData icon;
  final String label;
  final Color stripColor;
  final Color foreground;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: stripColor,
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.base * 2),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.base * 1.5,
          vertical: AppSpacing.base,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 拖拽位移较小时按比例缩小图标，避免溢出。
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(icon, color: foreground, size: 26),
            ),
            SizedBox(height: AppSpacing.base * 0.5),
            Text(
              label,
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
}
