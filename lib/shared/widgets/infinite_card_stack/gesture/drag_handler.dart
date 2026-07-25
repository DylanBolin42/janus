import 'package:flutter/widgets.dart';
import '../infinite_card_stack_state.dart';

/// A widget that handles drag gestures for the infinite card stack.
///
/// It translates touch movements into continuous scroll progress updates
/// and triggers appropriate swipe-to-dismiss or spring-back snapping on release.
class InfiniteCardStackDragHandler extends StatefulWidget {
  /// The internal state controller of the stack.
  final InfiniteCardStackState state;

  /// The child layout widget.
  final Widget child;

  /// Creates a drag handler.
  const InfiniteCardStackDragHandler({
    super.key,
    required this.state,
    required this.child,
  });

  @override
  State<InfiniteCardStackDragHandler> createState() =>
      _InfiniteCardStackDragHandlerState();
}

class _InfiniteCardStackDragHandlerState
    extends State<InfiniteCardStackDragHandler> {
  Offset? _startLocalPosition;
  double _initialScrollPosition = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onPanCancel: _handlePanCancel,
      child: widget.child,
    );
  }

  void _handlePanStart(DragStartDetails details) {
    if (widget.state.isAnimating) return;

    _startLocalPosition = details.localPosition;
    _initialScrollPosition = widget.state.scrollPosition;
    widget.state.onDragStart();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final startPos = _startLocalPosition;
    if (startPos == null) return;

    final currentPos = details.localPosition;
    final deltaX = currentPos.dx - startPos.dx;

    // Scale horizontal drag displacement to a fractional progress (0.0 to 1.0)
    // using the drag threshold.
    final threshold = widget.state.theme.dragThreshold;
    final progress = (deltaX / threshold).clamp(-1.0, 1.0);

    // If swiping right, progress is positive.
    // Update flight direction parameter so that the card flies in the swiped direction.
    widget.state.updateSwipeDirection(deltaX >= 0 ? 1.0 : -1.0);

    // Update the continuous scroll position in the state
    // Supporting positive progress (going forward).
    // For dating card style: swiping either left or right advances to the next card.
    final targetProgress = progress.abs();
    widget.state.updateScrollPositionDuringDrag(_initialScrollPosition + targetProgress);
  }

  void _handlePanEnd(DragEndDetails details) {
    final startPos = _startLocalPosition;
    if (startPos == null) return;

    _startLocalPosition = null;

    final currentProgress = widget.state.scrollPosition - _initialScrollPosition;

    // Check velocity and displacement to see if we should complete the card swipe or bounce back.
    final velocityX = details.velocity.pixelsPerSecond.dx;
    final isFastSwipe = velocityX.abs() > 800.0;
    final isPastThreshold = currentProgress >= 0.4; // 40% is enough to trigger dismiss

    if (isFastSwipe || isPastThreshold) {
      // Complete the swipe and animate forward to the next index
      widget.state.animateToNextFromDrag();
    } else {
      // Cancel the swipe and snap back to the current index
      widget.state.snapBackFromDrag();
    }
  }

  void _handlePanCancel() {
    if (_startLocalPosition != null) {
      _startLocalPosition = null;
      widget.state.snapBackFromDrag();
    }
  }
}
