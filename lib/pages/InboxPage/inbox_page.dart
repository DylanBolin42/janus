import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/theme/theme.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:m3e_dismissible/m3e_dismissible.dart';
import 'package:material_3_expressive/components/buttons/enums/m3e_button_enums.dart';
import 'package:material_3_expressive/components/buttons/styles/m3e_button_decoration.dart';
import 'package:material_3_expressive/components/toggle_button_group/models/m3e_button_group_action.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:reel_text/reel_text.dart';

/// 首页轮播的三种模式（有序循环）
const List<String> _inboxModes = ['EMERGENCY', 'PLANNED', 'COMING'];

/// 当前模式索引（Riverpod 状态）
class _CurrentModeIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void cycle(int delta, int total) {
    state = (state + delta + total) % total;
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
    ref
        .read(_currentModeIndexProvider.notifier)
        .cycle(delta, _inboxModes.length);
  }

  /// 实现任务列表搭建的模块
  Widget _buildTaskList({required List<String> items}) {
    //TODO: 需要添加真实查询逻辑
    return M3EDismissibleCardList(
      itemCount: items.length,
      itemBuilder: (ctx, i) => Text(items[i]),
      onDismiss: (i, dir) async {
        items.removeAt(i);
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
      child: Material(
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

                    // 任务显示切换器（M3E ButtonGroup）
                    Container(
                      width: double.infinity,
                      height: 100,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.base,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(128),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // 圆形箭头按钮直径（与中心胶囊同高）
                          const double circleWidth = 80;
                          // 中心按钮撑满剩余宽度（等效原 Expanded）
                          final double centerWidth =
                              constraints.maxWidth -
                              circleWidth * 2 -
                              AppSpacing.base * 2;
                          return M3EButtonGroup(
                            type: M3EButtonGroupType.standard,
                            shape: M3EButtonShape.round,
                            size: M3EButtonSize.custom(height: 80),
                            spacing: AppSpacing.base,
                            direction: Axis.horizontal,
                            // 中心按钮恒为选中态（当前模式）；点击箭头切换模式
                            selectedIndex: 1,
                            onSelectedIndexChanged: (index) {
                              if (index == 0) {
                                _cycleMode(-1);
                              } else {
                                _cycleMode(1);
                              }
                            },
                            actions: [
                              M3EButtonGroupAction(
                                width: circleWidth,
                                icon: Icon(
                                  Icons.keyboard_arrow_left_rounded,
                                  size: 70,
                                ),
                                decoration: M3EToggleButtonDecoration.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onSecondaryContainer,
                                ),
                              ),
                              M3EButtonGroupAction(
                                width: centerWidth,
                                label: ReelText.controller(
                                  controller: _modeController,
                                  style: TextStyle(
                                    fontFamily: 'AntonTitle',
                                    fontSize: 30,
                                  ),
                                ),
                                decoration: M3EToggleButtonDecoration.styleFrom(
                                  checkedRadius: 64,
                                  connectedInnerRadius: 64,
                                  borderRadius: 64.0,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              M3EButtonGroupAction(
                                width: circleWidth,
                                icon: Icon(
                                  Icons.keyboard_arrow_right_rounded,
                                  size: 70,
                                ),
                                decoration: M3EToggleButtonDecoration.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: AppSpacing.base),

                    // 任务卡片显示区域
                    //TODO: 需要在接入数据库后对接
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
