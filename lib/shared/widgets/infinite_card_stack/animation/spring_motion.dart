import 'dart:math' as math;

/// Implementation of a damped spring simulation (harmonic oscillator).
///
/// Used for high-fidelity spring-back animation feel when drag is released
/// and cards bounce back to their rest positions.
class SpringMotion {
  /// The spring stiffness coefficient (higher means faster oscillations).
  final double stiffness;

  /// The spring damping ratio (1.0 is critically damped, < 1.0 is underdamped).
  final double damping;

  /// Creates a [SpringMotion] solver.
  const SpringMotion({
    this.stiffness = 180.0,
    this.damping = 15.0,
  });

  /// Evaluates the displacement coefficient at fractional time [t] (from 0.0 to 1.0).
  ///
  /// Maps 0.0 to 0.0 and 1.0 to 1.0 with a realistic spring overshoot and settling.
  double evaluate(double t) {
    if (t <= 0.0) return 0.0;
    if (t >= 1.0) return 1.0;

    // Numerical evaluation of a damped spring starting at 0 and targeting 1
    // Using a standard spring equation: x(t) = 1 - e^(-d*t) * (cos(w*t) + (d/w)*sin(w*t))
    final d = damping;
    final w = math.sqrt(math.max(0.0, stiffness - d * d));

    // Scale t to simulate appropriate real-time duration (e.g., 0 to 1 second)
    final time = t * 1.5;

    if (w == 0.0) {
      // Critically damped or overdamped fallback
      return 1.0 - math.exp(-d * time) * (1.0 + d * time);
    }

    final envelope = math.exp(-d * time);
    final cosVal = math.cos(w * time);
    final sinVal = math.sin(w * time);

    return 1.0 - envelope * (cosVal + (d / w) * sinVal);
  }
}
