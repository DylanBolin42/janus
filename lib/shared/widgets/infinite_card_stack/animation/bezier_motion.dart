import 'dart:ui';
import '../utils/math.dart';

/// Class responsible for calculating the Bezier flight path of a card
/// as it is dismissed from the top of the stack and curves down to the bottom.
class BezierMotion {
  /// The control point horizontal offset multiplier.
  final double flightWidthFactor;

  /// The height of the Bezier curve peak relative to the vertical midpoint.
  final double bezierHeight;

  /// Creates a [BezierMotion] solver.
  const BezierMotion({
    this.flightWidthFactor = 1.2,
    this.bezierHeight = 100.0,
  });

  /// Calculates the horizontal and vertical offset of the flying card
  /// at progress [t], where [t] goes from 0.0 (top) to 1.0 (bottom).
  ///
  /// [start] is the position of the card at the top.
  /// [end] is the position of the card at the bottom.
  /// [containerWidth] is the total available width used to scale the horizontal flight.
  Offset calculateFlightOffset({
    required double t,
    required Offset start,
    required Offset end,
    required double containerWidth,
  }) {
    // Control point P1 lies to the right of the stack
    final flightWidth = containerWidth * flightWidthFactor;
    final p1 = Offset(
      flightWidth,
      (start.dy + end.dy) / 2 - bezierHeight,
    );

    return InfiniteCardStackMath.evaluateQuadraticBezier(start, p1, end, t);
  }

  /// Calculates the rotation angle (in radians) along the Bezier flight path.
  ///
  /// Adds dynamic flavor by rotating the card as it flies out and straightening
  /// it as it merges back into the bottom of the stack.
  double calculateFlightRotation({
    required double t,
    required double maxRotation,
  }) {
    // Rotates the card clockwise to maxRotation at t = 0.5,
    // then returns back to 0.0 at t = 1.0.
    if (t < 0.5) {
      final progress = t / 0.5;
      return maxRotation * progress;
    } else {
      final progress = (1.0 - t) / 0.5;
      return maxRotation * progress;
    }
  }
}
