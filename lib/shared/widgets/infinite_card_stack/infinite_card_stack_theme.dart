import 'package:flutter/widgets.dart';

/// Styling theme and configuration options for the [InfiniteCardStack].
///
/// Houses all spacing, scale, opacity, rotation, shadow, bezier and swipe
/// properties, allowing deep customization while preserving outstanding defaults.
@immutable
class InfiniteCardStackTheme {
  /// The number of simultaneously visible cards in the stack.
  ///
  /// Defaults to 4.
  final int visibleCount;

  /// The vertical spacing offset (in logical pixels) between consecutive card layers.
  ///
  /// Default changed to 0.0 to avoid visual distraction of stacked cards under rest.
  final double spacing;

  /// The scale of the bottom-most visible card layer.
  ///
  /// Each intermediate layer's scale is linearly interpolated between 1.0 and [minScale].
  /// Default changed to 1.0 to avoid visual distraction of stacked cards.
  final double minScale;

  /// The opacity of the bottom-most visible card layer.
  ///
  /// Each intermediate layer's opacity is linearly interpolated between 1.0 and [minOpacity].
  /// Default changed to 0.0 to completely hide lower cards under rest to avoid visual clutter.
  final double minOpacity;

  /// The physical shadow elevation of the topmost card.
  ///
  /// Lower cards' elevations are reduced proportionally down to 0.0.
  /// Defaults to 4.0.
  final double maxElevation;

  /// The incremental rotation step (in radians) applied to lower card layers to create a gorgeous
  /// layered visual effect. Alternates between positive and negative rotations.
  ///
  /// Defaults to 0.0. Pass e.g. 0.015 for messy Expressive look.
  final double stackRotationStep;

  /// The height peak of the quadratic Bezier flight path of a card being swiped or advanced.
  ///
  /// Defaults to 120.0.
  final double bezierHeight;

  /// Multiplier of container width indicating how far the card will swing to the side.
  ///
  /// Defaults to 1.2.
  final double flightWidthFactor;

  /// The maximum rotation angle in radians that a card undergoes during its Bezier flight path.
  ///
  /// Defaults to 0.25 (approx 14 degrees).
  final double maxFlightRotation;

  /// The drag distance in logical pixels needed to trigger a swipe-to-dismiss gesture.
  ///
  /// Defaults to 220.0.
  final double dragThreshold;

  /// The default duration of transitions (next, previous, animateTo, jumpTo).
  ///
  /// Defaults to 500 milliseconds.
  final Duration animationDuration;

  /// The standard motion transition curve.
  ///
  /// Defaults to [Curves.easeOutCubic] for ultra-smooth fluid movement.
  final Curve animationCurve;

  /// Creates an [InfiniteCardStackTheme] with highly-tuned, beautiful defaults.
  const InfiniteCardStackTheme({
    this.visibleCount = 4,
    this.spacing = 0.0,
    this.minScale = 1.0,
    this.minOpacity = 0.0,
    this.maxElevation = 4.0,
    this.stackRotationStep = 0.0,
    this.bezierHeight = 120.0,
    this.flightWidthFactor = 1.2,
    this.maxFlightRotation = 0.25,
    this.dragThreshold = 220.0,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeOutCubic,
  })  : assert(visibleCount >= 2),
        assert(minScale > 0.0 && minScale <= 1.0),
        assert(minOpacity >= 0.0 && minOpacity <= 1.0),
        assert(dragThreshold > 0.0);
}
