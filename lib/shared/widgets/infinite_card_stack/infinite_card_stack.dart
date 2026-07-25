import 'dart:async';
import 'package:flutter/material.dart';

import 'infinite_card_stack_controller.dart';
import 'infinite_card_stack_delegate.dart';
import 'infinite_card_stack_state.dart';
import 'infinite_card_stack_theme.dart';
import 'animation/card_animation.dart';
import 'gesture/drag_handler.dart';
import 'layout/stack_layout.dart';
import 'models/card_transform.dart';

/// A high-performance, custom infinite card stack widget.
///
/// Only instantiates `visibleCount + 1` widgets to conserve memory, lazily compiling
/// contents and performing flawless recycler shifting when cycling cards.
/// Moves cards along quadratic Bezier paths with dynamic depth (z-index) sorting,
/// completely avoiding flashes, rebuilding, or structural widget removals.
class InfiniteCardStack extends StatefulWidget {
  /// The item builder delegate.
  final InfiniteCardStackDelegate delegate;

  /// Layout styling and parameter configurations.
  final InfiniteCardStackTheme theme;

  /// External controller to drive the stack programmatically.
  final InfiniteCardStackController? controller;

  /// Whether to automatically cycle/rotate cards over time.
  final bool autoPlay;

  /// The duration between automatic transitions.
  final Duration autoPlayInterval;

  /// Whether to suspend auto-play when the user is actively swiping cards.
  final bool pauseOnTouch;

  /// Creates an on-demand, lazy-loading infinite card stack.
  InfiniteCardStack.builder({
    super.key,
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    this.theme = const InfiniteCardStackTheme(),
    this.controller,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.pauseOnTouch = true,
  }) : delegate = InfiniteCardStackDelegate(
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );

  @override
  State<InfiniteCardStack> createState() => _InfiniteCardStackState();
}

class _InfiniteCardStackState extends State<InfiniteCardStack>
    with TickerProviderStateMixin {
  late InfiniteCardStackState _state;
  late CardAnimationCalculator _calculator;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _initState();
  }

  void _initState() {
    _state = InfiniteCardStackState(
      theme: widget.theme,
      itemCount: widget.delegate.itemCount,
      vsync: this,
    );
    _calculator = CardAnimationCalculator(theme: widget.theme);

    // Attach controller if provided
    widget.controller?.attach(_state);

    // Start autoPlay if enabled
    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }

  @override
  void didUpdateWidget(covariant InfiniteCardStack oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If itemCount or theme changes, rebuild internal states
    if (oldWidget.delegate.itemCount != widget.delegate.itemCount ||
        oldWidget.theme != widget.theme) {
      widget.controller?.detach(_state);
      _state.dispose();
      _initState();
    } else if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach(_state);
      widget.controller?.attach(_state);
    }

    // Handle autoplay state adjustments
    if (oldWidget.autoPlay != widget.autoPlay ||
        oldWidget.autoPlayInterval != widget.autoPlayInterval) {
      _stopAutoPlay();
      if (widget.autoPlay) {
        _startAutoPlay();
      }
    }
  }

  @override
  void dispose() {
    _stopAutoPlay();
    widget.controller?.detach(_state);
    _state.dispose();
    super.dispose();
  }

  // ==========================================
  // Auto Play Timer Lifecycle
  // ==========================================

  void _startAutoPlay() {
    _stopAutoPlay();
    if (widget.delegate.itemCount <= 1) return;

    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (timer) {
      // Rotate next only if the user is not touching or already mid-animation
      if (widget.pauseOnTouch && (_state.isDragging || _state.isAnimating)) {
        return;
      }
      _state.next();
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  // ==========================================
  // Widget Builder
  // ==========================================

  @override
  Widget build(BuildContext context) {
    if (widget.delegate.itemCount == 0) {
      return const SizedBox.shrink();
    }

    final totalSlots = widget.theme.visibleCount + 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        return InfiniteCardStackDragHandler(
          state: _state,
          child: ValueListenableBuilder<double>(
            valueListenable: _state.scrollPositionNotifier,
            builder: (context, scrollPosition, _) {
              final baseIndex = scrollPosition.floor();

              // Calculate synchronized transforms for all active logical levels
              final calculatedTransforms = _calculator.calculateTransforms(
                scrollPosition: scrollPosition,
                containerWidth: constraints.maxWidth,
              );

              // Map logical layer transforms to their corresponding physical card slots
              final physicalTransforms = List<CardTransform>.filled(
                totalSlots,
                const CardTransform.identity(),
              );

              for (var j = 0; j < totalSlots; j++) {
                final k = baseIndex + j;
                final slotIndex = k % totalSlots;
                physicalTransforms[slotIndex] = calculatedTransforms[j];
              }

              // Lazy-generate exactly `visibleCount + 1` widgets
              final children = List<Widget>.generate(totalSlots, (slotIndex) {
                // Find the unique logical index currently mapped to this physical slot
                var logicalIndex = baseIndex;
                for (var offset = 0; offset < totalSlots; offset++) {
                  final k = baseIndex + offset;
                  if (k % totalSlots == slotIndex) {
                    logicalIndex = k;
                    break;
                  }
                }

                // Retrieve the child, cached and built on-demand
                return widget.delegate.build(context, logicalIndex);
              });

              return InfiniteCardStackLayout(
                transforms: physicalTransforms,
                children: children,
              );
            },
          ),
        );
      },
    );
  }
}
