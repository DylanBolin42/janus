import 'package:flutter/foundation.dart';
import 'infinite_card_stack_state.dart';

/// Public controller to programmatically manipulate the [InfiniteCardStack].
///
/// Can trigger next/previous card actions, jump/animate to index points, and
/// read the active state variables (isAnimating, currentIndex).
class InfiniteCardStackController extends ChangeNotifier {
  InfiniteCardStackState? _state;

  /// Attaches a state instance to this controller.
  ///
  /// For internal framework use only.
  void attach(InfiniteCardStackState state) {
    assert(_state == null, 'Controller is already attached to an active InfiniteCardStack.');
    _state = state;
    _state!.addListener(notifyListeners);
  }

  /// Detaches the currently bound state.
  ///
  /// For internal framework use only.
  void detach(InfiniteCardStackState state) {
    if (_state == state) {
      _state!.removeListener(notifyListeners);
      _state = null;
    }
  }

  /// The currently resting integer index of the top card.
  int get currentIndex {
    final state = _state;
    if (state == null) return 0;
    return state.currentIndex;
  }

  /// Whether the card stack is currently animating a transition.
  bool get isAnimating {
    final state = _state;
    if (state == null) return false;
    return state.isAnimating;
  }

  /// Transitions smoothly to the next card in the deck.
  void next() {
    _state?.next();
  }

  /// Transitions smoothly to the previous card.
  void previous() {
    _state?.previous();
  }

  /// Animates the stack smoothly to a specific target index.
  void animateTo(int index) {
    _state?.animateTo(index);
  }

  /// Jumps instantly to a specific target index.
  void jumpTo(int index) {
    _state?.jumpTo(index.toDouble());
  }

  /// Disposes resources.
  @override
  void dispose() {
    _state = null;
    super.dispose();
  }
}
