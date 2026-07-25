import '../models/card_transform.dart';

/// Utility methods for performing linear interpolations.
class InfiniteCardStackLerp {
  InfiniteCardStackLerp._();

  /// Linearly interpolates between two lists of [CardTransform]s.
  ///
  /// Assumes both lists are of the same length. If lengths differ, it falls
  /// back to matching indices or appending default values.
  static List<CardTransform> lerpTransformList(
    List<CardTransform> a,
    List<CardTransform> b,
    double t,
  ) {
    if (t == 0.0) return a;
    if (t == 1.0) return b;

    final length = a.length < b.length ? a.length : b.length;
    final result = <CardTransform>[];

    for (var i = 0; i < length; i++) {
      result.add(a[i].lerpTo(b[i], t));
    }

    // Handle length mismatches gracefully by appending remaining transforms
    if (a.length < b.length) {
      for (var i = length; i < b.length; i++) {
        result.add(b[i]);
      }
    } else if (a.length > b.length) {
      for (var i = length; i < a.length; i++) {
        result.add(a[i]);
      }
    }

    return result;
  }

  /// Linearly interpolates a single double value.
  static double lerpDoubleValue(double begin, double end, double t) {
    return begin + (end - begin) * t;
  }
}
