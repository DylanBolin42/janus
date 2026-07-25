import 'package:flutter/widgets.dart';
import 'infinite_card_stack_theme.dart';

/// The underlying state coordinator for the infinite card stack.
///
/// Manages tickers, continuous scroll positions, gesture state updates,
/// and auto-play cycles. Exposes values via highly-optimized [ValueNotifier]s
/// to ensure stable 60/120 FPS performance by skipping unnecessary widget rebuilds.
class InfiniteCardStackState extends ChangeNotifier {
  /// The styling and layout theme.
  final InfiniteCardStackTheme theme;

  /// The total count of items in the stack.
  final int itemCount;

  /// Ticker provider used to drive smooth transitions.
  final TickerProvider vsync;

  /// The current flight direction multiplier: 1.0 for right, -1.0 for left.
  double swipeDirection = 1.0;

  /// Value notifier tracking the active fractional page/scroll position of the deck.
  ///
  /// For example, `3.0` means the stack is at rest at index 3.
  /// `3.4` means index 3 is 40% swiped away toward index 4.
  late final ValueNotifier<double> scrollPositionNotifier;

  late final AnimationController _transitionController;

  /// Base index at the start of any animation or gesture transition.
  double _baseScrollPosition = 0.0;

  /// Flag indicating if an automatic or gesture-driven animation is currently running.
  bool isAnimating = false;

  /// Flag indicating if the user is currently touching and dragging the stack.
  bool isDragging = false;

  /// Creates a stack state.
  InfiniteCardStackState({
    required this.theme,
    required this.itemCount,
    required this.vsync,
    double initialPosition = 0.0,
  }) {
    scrollPositionNotifier = ValueNotifier<double>(initialPosition);
    _baseScrollPosition = initialPosition;
    _transitionController = AnimationController(
      vsync: vsync,
      duration: theme.animationDuration,
    );
    _transitionController.addListener(_onTransitionTick);
    _transitionController.addStatusListener(_onTransitionStatusChanged);
  }

  /// The current continuous position of the stack.
  double get scrollPosition => scrollPositionNotifier.value;

  /// The current resting integer index in the dataset.
  int get currentIndex {
    if (itemCount == 0) return 0;
    return (scrollPosition.round()) % itemCount;
  }

  /// Cleans up tickers and resources.
  @override
  void dispose() {
    _transitionController.removeListener(_onTransitionTick);
    _transitionController.removeStatusListener(_onTransitionStatusChanged);
    _transitionController.dispose();
    scrollPositionNotifier.dispose();
    super.dispose();
  }

  // ==========================================
  // Gesture Handling Actions
  // ==========================================

  /// Call when drag begins to suspend autoplay and prep visual variables.
  void onDragStart() {
    isDragging = true;
    _transitionController.stop();
    _baseScrollPosition = scrollPosition;
    notifyListeners();
  }

  /// Updates the flight swipe direction (left vs right) dynamically.
  void updateSwipeDirection(double direction) {
    if (swipeDirection != direction) {
      swipeDirection = direction;
      notifyListeners();
    }
  }

  /// Direct touch callback to update the layout dynamically during swipe.
  void updateScrollPositionDuringDrag(double position) {
    scrollPositionNotifier.value = position;
  }

  /// Completes the swipe animation by sliding the card the rest of the way.
  void animateToNextFromDrag() {
    isDragging = false;
    isAnimating = true;
    notifyListeners();

    final currentProgress = scrollPosition - _baseScrollPosition;
    _transitionController.value = currentProgress;

    _transitionController.animateTo(
      1.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// Snaps cards back to their rest positions when drag fails to clear the threshold.
  void snapBackFromDrag() {
    isDragging = false;
    isAnimating = true;
    notifyListeners();

    final currentProgress = scrollPosition - _baseScrollPosition;
    _transitionController.value = currentProgress;

    // Use elastic curve or custom overshoot to feel bouncy
    _transitionController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
    );
  }

  // ==========================================
  // Programmatic Controller APIs
  // ==========================================

  /// Transitions smoothly to the next card in the stack.
  void next() {
    if (isAnimating || itemCount <= 1) return;

    isAnimating = true;
    swipeDirection = 1.0; // Default next flies right
    notifyListeners();

    _baseScrollPosition = scrollPosition.floorToDouble();
    scrollPositionNotifier.value = _baseScrollPosition;

    _transitionController.value = 0.0;
    _transitionController.animateTo(
      1.0,
      duration: theme.animationDuration,
      curve: theme.animationCurve,
    );
  }

  /// Transitions smoothly to the previous card.
  ///
  /// Animates by setting the base at target, starting progress at 1.0 and sliding back to 0.0.
  void previous() {
    if (isAnimating || itemCount <= 1) return;

    isAnimating = true;
    swipeDirection = -1.0; // Default previous flies left
    notifyListeners();

    // Start 1.0 ahead and slide backwards to 0.0
    _baseScrollPosition = (scrollPosition - 1.0).floorToDouble();
    if (_baseScrollPosition < 0.0) {
      _baseScrollPosition = itemCount - 1.0;
    }
    scrollPositionNotifier.value = _baseScrollPosition + 1.0;

    _transitionController.value = 1.0;
    _transitionController.animateTo(
      0.0,
      duration: theme.animationDuration,
      curve: theme.animationCurve,
    );
  }

  /// Transitions smoothly to an arbitrary index.
  void animateTo(int index) {
    if (isAnimating || itemCount <= 1 || index == currentIndex) return;

    // To prevent infinite multi-spin visuals, we transition next/prev once directly to the target.
    // If target is far away, we can jump close to it first, then animate.
    final int distance = index - currentIndex;
    if (distance.abs() == 1) {
      if (distance > 0) {
        next();
      } else {
        previous();
      }
    } else {
      // Jump next to the target and do a smooth transition
      final double prepPosition = index > currentIndex
          ? (index - 1).toDouble()
          : (index + 1).toDouble();

      jumpTo(prepPosition);
      if (index > currentIndex) {
        next();
      } else {
        previous();
      }
    }
  }

  /// Jumps instantly to a specific index with zero animation.
  void jumpTo(double position) {
    _transitionController.stop();
    isAnimating = false;
    isDragging = false;
    _baseScrollPosition = position;
    scrollPositionNotifier.value = position;
    notifyListeners();
  }

  // ==========================================
  // Internal Tick Receivers
  // ==========================================

  void _onTransitionTick() {
    if (isAnimating) {
      scrollPositionNotifier.value = _baseScrollPosition + _transitionController.value;
    }
  }

  void _onTransitionStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
      isAnimating = false;

      // Lock onto final integer position
      final double finalPos = scrollPositionNotifier.value.roundToDouble();
      _baseScrollPosition = finalPos;
      scrollPositionNotifier.value = finalPos;

      notifyListeners();
    }
  }
}
