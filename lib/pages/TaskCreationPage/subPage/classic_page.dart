import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/providers/database_provider.dart';
import 'package:janus/providers/task_draft_provider.dart';
import 'package:janus/services/logger_service.dart';
import 'package:janus/theme/theme.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

class ClassicPage extends ConsumerStatefulWidget {
  const ClassicPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ClassicPageState();
}

class _ClassicPageState extends ConsumerState<ClassicPage> {
  TextTheme get tt => Theme.of(context).textTheme;
  int _priorityIndex = 0;
  int _taskMode = 0; //INFO: 0代表任务，1代表日程

  int _previousTaskMode = 0; // 记录切换前的模式，用于判断滑动方向

  /// 标签下拉框 controller，用于在菜单内动态新增标签项。
  final M3EDropdownController<String> _tagController =
      M3EDropdownController<String>();

  /// 标签全集（与 [_tagController] 保持一致），初始从 drift tags 表加载，
  /// 创建新标签时做大小写不敏感去重并同步。
  final List<M3EDropdownItem<String>> _tagItems = [];

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  /// 从 drift tags 表加载全部标签并填充下拉框。
  Future<void> _loadTags() async {
    try {
      final tags = await ref.read(taskDaoProvider).getAllTags();
      if (!mounted) return;
      setState(() {
        _tagItems
          ..clear()
          ..addAll(
            tags.map((t) => M3EDropdownItem(label: t.name, value: t.name)),
          );
      });
      _tagController.setItems(_tagItems);
    } catch (e, stackTrace) {
      AppLogger.e('加载标签失败', error: e, stackTrace: stackTrace);
    }
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  /// 在菜单内创建新标签：与已有标签（大小写不敏感）重名时直接选中，否则新建并选中。
  Future<void> _createTag(String rawQuery) async {
    final label = rawQuery.trim();
    if (label.isEmpty) return;
    final normalized = label.toLowerCase();

    final existing = _tagItems
        .where((item) => item.label.toLowerCase() == normalized)
        .toList();
    if (existing.isNotEmpty) {
      _tagController.selectWhere((item) => item.value == existing.first.value);
      return;
    }

    // 数据库写入
    try {
      await ref.read(taskDaoProvider).createTag(label);
    } catch (e, stackTrace) {
      AppLogger.e('标签创建失败', error: e, stackTrace: stackTrace);
      return;
    }

    // 如果写入成功则刷新UI
    AppLogger.i('标签 $label 创建成功');
    final item = M3EDropdownItem(label: label, value: label);
    setState(() => _tagItems.add(item));
    _tagController
      ..addItem(item)
      ..selectWhere((item) => item.value == label);
  }

  /// 搜索无结果时显示的"创建新标签"入口。
  Widget _buildCreateTagEntry(BuildContext context) {
    final query = _tagController.searchQuery.trim();
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: query.isEmpty
            ? null
            : () => _createTag(_tagController.searchQuery),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.add_rounded, size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  query.isEmpty ? '输入文字以创建新标签' : '创建 "$query"',
                  style: tt.bodySmall?.copyWith(color: scheme.primary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 与 WoltModalSheet 的断点保持一致：< 523 为移动端底部弹出，>= 523 为桌面端侧边弹出
  bool get _isMobile => MediaQuery.of(context).size.width < 523;

  void _switchMode(int index) {
    if (index == _taskMode) return;
    setState(() {
      _previousTaskMode = _taskMode;
      _taskMode = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: GlassSegmentedControl(
            segments: [
              GlassSegment(label: '任务'),
              GlassSegment(label: '日程'),
            ],
            selectedIndex: _taskMode,
            onSegmentSelected: _switchMode,
          ),
        ),
        _buildContentArea(),
      ],
    );
  }

  /// 构建带动画过渡的内容区域。
  ///
  /// 移动端（宽度 < 523）：外层 [AnimatedSize] 驱动底部弹窗的高度伸缩动画，
  /// 内层 [AnimatedSwitcher] 驱动内容的左右滑动切换 —— 两者均使用弹簧曲线。
  ///
  /// 桌面端（宽度 >= 523）：仅使用 [AnimatedSwitcher] 做左右滑动切换，
  /// 侧边面板不需要高度伸缩。
  Widget _buildContentArea() {
    final animatedContent = _buildAnimatedSwitcher();

    if (_isMobile) {
      return AnimatedSize(
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        alignment: Alignment.topCenter,
        child: animatedContent,
      );
    }
    return animatedContent;
  }

  /// 构建带弹簧滑动 + 淡入淡出的内容切换器。
  Widget _buildAnimatedSwitcher() {
    // 向右切换为正（任务 → 日程），向左切换为负（日程 → 任务）
    final slideDirection = _previousTaskMode < _taskMode ? 1.0 : -1.0;

    return ClipRect(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: _isMobile ? Curves.elasticOut : Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(slideDirection * 0.25, 0),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: _taskMode == 0
            ? _buildTaskForm(key: const ValueKey('task'))
            : _buildSchedulePlaceholder(key: const ValueKey('schedule')),
      ),
    );
  }

  /// 任务表单内容
  Widget _buildTaskForm({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppSpacing.contentInterval),
        Text('任务标题', style: tt.bodyMedium),
        SizedBox(height: AppSpacing.base),
        SizedBox(
          width: double.infinity,
          child: TapRegion(
            onTapOutside: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: TextField(
              onChanged: (title) {
                ref.read(taskDraftProvider.notifier).setTitle(title);
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.contentInterval,
                  vertical: AppSpacing.contentInterval,
                ),
                filled: true,
                hintText: '任务标题',
                fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(32),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(32),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 3,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.contentInterval),
        Text('任务描述', style: tt.bodyMedium),
        SizedBox(height: AppSpacing.base),
        SizedBox(
          width: double.infinity,
          child: TapRegion(
            onTapOutside: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: TextField(
              onChanged: (description) {
                ref
                    .read(taskDraftProvider.notifier)
                    .setDescription(description);
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.contentInterval,
                  vertical: AppSpacing.contentInterval,
                ),
                hintText: '任务描述',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(16),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 3,
                  ),
                ),
              ),
              maxLines: 5,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.contentInterval),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.contentInterval),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('截止时间'),
                    Spacer(),
                    CupertinoCalendarPickerButton(
                      onDateTimeChanged: (value) {
                        ref.read(taskDraftProvider.notifier).setDdl(value);
                      },
                      minimumDateTime: DateTime(2010),
                      maximumDateTime: DateTime(2030),
                      mode: CupertinoCalendarMode.dateTime,
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.base),
                GlassDivider(),
                SizedBox(height: AppSpacing.base),
                Row(
                  children: [
                    Text('预计耗时'),
                    Spacer(),
                    CupertinoTimePickerButton(
                      onTimeChanged: (value) {
                        ref.read(taskDraftProvider.notifier).setEst(value);
                      },
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.base),
                GlassDivider(),
                SizedBox(height: AppSpacing.base),
                Row(
                  children: [
                    Text('优先级'),
                    Spacer(),
                    SizedBox(
                      width: 200,
                      child: GlassSegmentedControl(
                        onSegmentSelected: (index) {
                          setState(() => _priorityIndex = index);
                          ref
                              .read(taskDraftProvider.notifier)
                              .setPriority(index);
                        },
                        selectedIndex: _priorityIndex,
                        segments: [
                          GlassSegment(label: '无'),
                          GlassSegment(label: '低'),
                          GlassSegment(label: '中'),
                          GlassSegment(label: '高'),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.base),
                GlassDivider(),
                SizedBox(height: AppSpacing.base),
                Row(
                  children: [
                    Text('标签'),
                    Spacer(),
                    SizedBox(
                      width: 200,
                      child: M3EDropdownMenu<String>(
                        singleSelect: false,
                        searchEnabled: true,
                        controller: _tagController,
                        items: const [],
                        emptyBuilder: _buildCreateTagEntry,
                        searchStyle: M3EDropdownSearchStyle(
                          textStyle: Theme.of(context).textTheme.bodySmall,
                        ),
                        itemStyle: M3EDropdownItemStyle(
                          textStyle: Theme.of(context).textTheme.bodySmall,
                          selectedTextStyle: Theme.of(
                            context,
                          ).textTheme.bodySmall,
                          selectedBackgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          selectedTextColor: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                        ),
                        fieldStyle: M3EDropdownFieldStyle(
                          hintText: '请选择标签',
                          hintStyle: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          selectedTextStyle: Theme.of(
                            context,
                          ).textTheme.bodySmall,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          errorStyle: Theme.of(context).textTheme.bodySmall,
                        ),
                        onSelectionChanged: (items) {
                          ref
                              .read(taskDraftProvider.notifier)
                              .setTags(items.map((e) => e.value).toList());
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 日程模式占位内容
  Widget _buildSchedulePlaceholder({Key? key}) {
    return SizedBox(
      key: key,
      height: 200,
      child: Center(
        child: Text(
          '日程模式开发中...',
          style: tt.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
