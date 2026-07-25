import 'package:flutter/material.dart';
import '../../shared/widgets/infinite_card_stack/infinite_card_stack.dart';
import '../../shared/widgets/infinite_card_stack/infinite_card_stack_controller.dart';
import '../../shared/widgets/infinite_card_stack/infinite_card_stack_theme.dart';

/// Interactive Demo Page illustrating the capabilities of the [InfiniteCardStack] component.
///
/// Showcases:
/// 1. Lazy-loading with a massive dataset (1000 items).
/// 2. Auto-play toggle and status indicators.
/// 3. Manual Controller operations (next, previous, jumpTo, animateTo).
/// 4. Dynamic visual parameters (spacing, rotation offsets, scales).
class InfiniteCardStackDemo extends StatefulWidget {
  /// Creates the demo page.
  const InfiniteCardStackDemo({super.key});

  @override
  State<InfiniteCardStackDemo> createState() => _InfiniteCardStackDemoState();
}

class _InfiniteCardStackDemoState extends State<InfiniteCardStackDemo> {
  late final InfiniteCardStackController _controller;

  // Create 1000 task card mock objects to prove lazy builder performance.
  final List<Map<String, dynamic>> _tasks = List.generate(1000, (index) {
    return {
      'id': 'TASK-${index + 1}',
      'title': '设计优雅卡片堆栈组件 #$index',
      'description': '使用 Flutter 自定义高帧率组件，包含贝塞尔曲线运动、弹性弹簧插值与无损缓存复用。',
      'index': index,
      'color': _getGradientForIndex(index),
    };
  });

  bool _autoPlay = false;
  double _spacing = 18.0;
  double _stackRotation = 0.015;
  int _visibleCount = 4;

  @override
  void initState() {
    super.initState();
    _controller = InfiniteCardStackController();
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    // Triggers rebuild of headers when active index switches
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  static LinearGradient _getGradientForIndex(int index) {
    final gradients = [
      const LinearGradient(
        colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFFF7971E), Color(0xFFFFD200)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF396AFC), Color(0xFF2948FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ];
    return gradients[index % gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    final currentTask = _tasks[_controller.currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('无限循环卡片堆栈演示'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Display Status Banner
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        child: Text('${_controller.currentIndex}'),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentTask['id'],
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                            Text(
                              currentTask['title'],
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _autoPlay ? Colors.green.withOpacity(0.15) : Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _autoPlay ? '自动轮播' : '手动控制',
                          style: TextStyle(
                            color: _autoPlay ? Colors.green[800] : Colors.orange[800],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24.0),

              // The high-performance card stack component
              SizedBox(
                height: 380.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: InfiniteCardStack.builder(
                    itemCount: _tasks.length,
                    controller: _controller,
                    autoPlay: _autoPlay,
                    autoPlayInterval: const Duration(seconds: 3),
                    theme: InfiniteCardStackTheme(
                      visibleCount: _visibleCount,
                      spacing: _spacing,
                      stackRotationStep: _stackRotation,
                    ),
                    itemBuilder: (context, index) {
                      final item = _tasks[index];
                      return Container(
                        decoration: BoxDecoration(
                          gradient: item['color'] as LinearGradient,
                          borderRadius: BorderRadius.circular(24.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 16.0,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24.0),
                          child: Stack(
                            children: [
                              // Decorative Background Sphere
                              Positioned(
                                right: -40,
                                top: -40,
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0, vertical: 6.0),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(20.0),
                                          ),
                                          child: Text(
                                            item['id'] as String,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.workspace_premium,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(
                                      item['title'] as String,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      item['description'] as String,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 14.0,
                                        height: 1.4,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Spacer(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '数据项 #${item['index']}',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 12.0,
                                          ),
                                        ),
                                        const Text(
                                          '滑动或点击控制 ->',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24.0),

              // Manual controls
              Text(
                '控制台',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _controller.previous(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('上一个'),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _controller.next(),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('下一个'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _controller.animateTo(8),
                      icon: const Icon(Icons.flash_on),
                      label: const Text('平滑移至 #8'),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _controller.jumpTo(100),
                      icon: const Icon(Icons.fast_forward),
                      label: const Text('瞬间跳转 #100'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24.0),

              // Settings sliders & options
              Text(
                '参数配置',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8.0),

              // AutoPlay switch
              SwitchListTile(
                title: const Text('启动自动轮播'),
                subtitle: const Text('开启后每 3 秒自动切换下一张'),
                value: _autoPlay,
                onChanged: (val) {
                  setState(() {
                    _autoPlay = val;
                  });
                },
              ),

              // Spacing slider
              ListTile(
                title: Text('堆栈高度差: ${_spacing.toStringAsFixed(1)} dp'),
                subtitle: Slider(
                  min: 5.0,
                  max: 40.0,
                  value: _spacing,
                  onChanged: (val) {
                    setState(() {
                      _spacing = val;
                    });
                  },
                ),
              ),

              // Rotation step slider
              ListTile(
                title: Text('卡片偏转角: ${(_stackRotation * 180 / 3.14159).toStringAsFixed(1)}°'),
                subtitle: Slider(
                  min: 0.0,
                  max: 0.05,
                  value: _stackRotation,
                  onChanged: (val) {
                    setState(() {
                      _stackRotation = val;
                    });
                  },
                ),
              ),

              // Visible Count selector
              ListTile(
                title: Text('可见卡片数: $_visibleCount 张'),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [2, 3, 4, 5].map((count) {
                      final isSelected = _visibleCount == count;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: ChoiceChip(
                          label: Text('$count 张'),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _visibleCount = count;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
