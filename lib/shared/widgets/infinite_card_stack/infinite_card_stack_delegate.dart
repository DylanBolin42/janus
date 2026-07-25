import 'package:flutter/widgets.dart';

/// Delegate that supplies children to [InfiniteCardStack] on-demand.
///
/// It enables lazy loading of card contents, ensuring that only the active visible layers
/// (specifically `visibleCount + 1` slots) are built and rendered at any given time,
/// rather than materializing the entire dataset.
class InfiniteCardStackDelegate {
  /// The total number of cards in the dataset.
  final int itemCount;

  /// Signature for building a card widget at a given [index].
  final IndexedWidgetBuilder itemBuilder;

  /// Creates a delegate for building infinite card stacks.
  const InfiniteCardStackDelegate({
    required this.itemCount,
    required this.itemBuilder,
  }) : assert(itemCount >= 0);

  /// Builds a card for the specified [index].
  Widget build(BuildContext context, int index) {
    // Gracefully handle bounds using modulo arithmetic for infinite loop behavior.
    final boundedIndex = itemCount > 0 ? index % itemCount : 0;
    return itemBuilder(context, boundedIndex);
  }
}
