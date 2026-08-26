import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blurrycontainer/blurrycontainer.dart';

/// Priority severity used for colour mapping.
enum TaskPriority { urgent, high, medium, low }

/// Extension that resolves a priority colour from the current [ColorScheme].
extension TaskPriorityColor on TaskPriority {
  Color resolve(ColorScheme cs) {
    switch (this) {
      case TaskPriority.urgent:
        return cs.primaryContainer;
      case TaskPriority.high:
        return cs.error;
      case TaskPriority.medium:
        return cs.tertiary;
      case TaskPriority.low:
        return cs.outline;
    }
  }
}

/// Parse a Chinese priority label into the enum.
TaskPriority taskPriorityFromString(String label) {
  switch (label) {
    case '紧急':
      return TaskPriority.urgent;
    case '高':
      return TaskPriority.high;
    case '中':
      return TaskPriority.medium;
    case '低':
      return TaskPriority.low;
    default:
      return TaskPriority.medium;
  }
}

class TaskCard extends ConsumerStatefulWidget {
  const TaskCard({
    required this.title,
    this.description,
    required this.isCompleted,
    required this.priority,
    required this.ddl,
    required this.est,
    this.onTap,
    this.onToggle,
    this.compact = false,
    super.key,
  });

  final String title;
  final String? description;
  final bool isCompleted;
  final String priority;
  final DateTime ddl;
  final TimeOfDay est;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggle;

  /// When true, reduces vertical padding and hides the description for a
  /// tighter card — used in flip-card sections (紧急 / 临近 / 计划).
  final bool compact;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<TaskCard> {
  late bool _completed;

  @override
  void initState() {
    super.initState();
    _completed = widget.isCompleted;
  }

  @override
  void didUpdateWidget(TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCompleted != widget.isCompleted) {
      _completed = widget.isCompleted;
    }
  }

  /// Format DDL as short readable string: "07/21 14:30"
  String _formatDdl(DateTime dt) =>
      '${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  /// Whether the DDL is within the next 6 hours.
  bool get _isUrgent =>
      widget.ddl.difference(DateTime.now()).inHours < 6 && !_completed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final TaskPriority pri = taskPriorityFromString(widget.priority);
    final Color badgeColor = pri.resolve(cs);

    return BlurryContainer(
      blur: 50,
      width: double.infinity,
      padding: widget.compact
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Checkbox ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 12),
              child: Semantics(
                label: 'Toggle task completion',
                value: _completed ? 'Completed' : 'Not completed',
                checked: _completed,
                button: true,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _completed = !_completed);
                    widget.onToggle?.call(_completed);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _completed ? cs.primary : Colors.transparent,
                      border: Border.all(
                        color: _completed
                            ? cs.primary
                            : cs.onSurface.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: _completed
                        ? Icon(Icons.check_rounded, size: 14, color: cs.onPrimary)
                        : null,
                  ),
                ),
              ),
            ),

            // ── Title + description ──────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: tt.bodyLarge?.copyWith(
                      decoration: _completed
                          ? TextDecoration.lineThrough
                          : null,
                      color: _completed
                          ? cs.onSurface.withValues(alpha: 0.45)
                          : cs.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.description != null &&
                      !_completed &&
                      !widget.compact) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.description!,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),

            // ── Meta column ─────────────────────────────────────────────
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Priority badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(64),
                    border: Border.all(
                      color: badgeColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    widget.priority,
                    style: tt.labelSmall?.copyWith(
                      color: badgeColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // DDL + EST in one line
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 12,
                      color: _isUrgent
                          ? cs.error
                          : cs.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatDdl(widget.ddl)} · '
                      '${widget.est.hour}h ${widget.est.minute}m',
                      style: tt.labelSmall?.copyWith(
                        color: _isUrgent
                            ? cs.error
                            : cs.onSurface.withValues(alpha: 0.55),
                        fontWeight: _isUrgent ? FontWeight.w600 : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
