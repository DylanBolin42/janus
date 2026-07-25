import 'package:flutter/material.dart';
import '../models/card_transform.dart';

/// A custom layout widget that displays card widgets at their calculated
/// transformed states and paints them in correct depth (zIndex) order.
class InfiniteCardStackLayout extends StatelessWidget {
  /// The list of card widgets to render.
  final List<Widget> children;

  /// The calculated transform properties for each child widget, matching
  /// indices.
  final List<CardTransform> transforms;

  /// Creates a layout container.
  const InfiniteCardStackLayout({
    super.key,
    required this.children,
    required this.transforms,
  }) : assert(children.length == transforms.length);

  @override
  Widget build(BuildContext context) {
    // We need to paint children in ascending order of zIndex so that
    // cards with higher zIndex are drawn on top of cards with lower zIndex.
    // To do this while keeping widget identity intact, we pair each widget
    // with its transform, sort the pairs by zIndex, and then build the Stack.
    final paired = List.generate(children.length, (index) {
      return _CardLayoutPair(
        widget: children[index],
        transform: transforms[index],
      );
    });

    paired.sort((a, b) => a.transform.zIndex.compareTo(b.transform.zIndex));

    return Stack(
      clipBehavior: Clip.none,
      children: paired.map((pair) {
        final t = pair.transform;

        // Combine translation, scaling, and rotation into a single high-performance Matrix4.
        // This is processed in a single layout/paint step.
        final matrix = Matrix4.identity()
          ..translate(t.offset.dx, t.offset.dy)
          ..scale(t.scale, t.scale)
          ..rotateZ(t.rotation);

        return Positioned.fill(
          child: Opacity(
            opacity: t.opacity,
            // RepaintBoundary isolates the card from paint updates while it is moving/animating,
            // avoiding expensive redraws of card content.
            child: RepaintBoundary(
              child: Transform(
                transform: matrix,
                alignment: Alignment.center,
                child: pair.widget,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CardLayoutPair {
  final Widget widget;
  final CardTransform transform;

  const _CardLayoutPair({
    required this.widget,
    required this.transform,
  });
}
