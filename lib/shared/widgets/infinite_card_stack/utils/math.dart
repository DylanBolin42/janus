import 'dart:ui';

/// Custom math helper utilities for infinite card stack layout,
/// including Bezier path calculations and spring easing factors.
class InfiniteCardStackMath {
  InfiniteCardStackMath._();

  /// Computes the point on a quadratic Bezier curve at progress [t].
  ///
  /// The formula is:
  /// B(t) = (1-t)^2 * p0 + 2*(1-t)*t * p1 + t^2 * p2
  static Offset evaluateQuadraticBezier(Offset p0, Offset p1, Offset p2, double t) {
    final u = 1.0 - t;
    final tt = t * t;
    final uu = u * u;

    final x = uu * p0.dx + 2 * u * t * p1.dx + tt * p2.dx;
    final y = uu * p0.dy + 2 * u * t * p1.dy + tt * p2.dy;

    return Offset(x, y);
  }

  /// Computes the tangent/velocity vector of a quadratic Bezier curve at progress [t].
  ///
  /// This is useful if we want to rotate cards along the direction of the Bezier flight path.
  /// The derivative formula is:
  /// B'(t) = 2*(1-t)*(p1 - p0) + 2*t*(p2 - p1)
  static Offset evaluateQuadraticBezierTangent(Offset p0, Offset p1, Offset p2, double t) {
    final u = 1.0 - t;
    final dx = 2 * u * (p1.dx - p0.dx) + 2 * t * (p2.dx - p1.dx);
    final dy = 2 * u * (p1.dy - p0.dy) + 2 * t * (p2.dy - p1.dy);
    return Offset(dx, dy);
  }

  /// Computes the point on a cubic Bezier curve at progress [t].
  ///
  /// The formula is:
  /// B(t) = (1-t)^3 * p0 + 3*(1-t)^2*t * p1 + 3*(1-t)*t^2 * p2 + t^3 * p3
  static Offset evaluateCubicBezier(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final u = 1.0 - t;
    final tt = t * t;
    final uu = u * u;
    final uuu = uu * u;
    final ttt = tt * t;

    final x = uuu * p0.dx + 3 * uu * t * p1.dx + 3 * u * tt * p2.dx + ttt * p3.dx;
    final y = uuu * p0.dy + 3 * uu * t * p1.dy + 3 * u * tt * p2.dy + ttt * p3.dy;

    return Offset(x, y);
  }
}
