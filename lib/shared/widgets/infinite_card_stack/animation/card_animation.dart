import 'dart:ui';
import '../models/card_transform.dart';
import '../infinite_card_stack_theme.dart';
import 'bezier_motion.dart';

/// Class responsible for calculating the precise [CardTransform] of every card
/// in the stack for any arbitrary fractional scroll position.
///
/// Ensures all card movements (translation, scale, rotation, opacity, depth) are
/// 100% synchronized and frame-perfect.
class CardAnimationCalculator {
  /// The visual theme and configuration.
  final InfiniteCardStackTheme theme;

  /// The Bezier motion helper for calculating dismissed card flights.
  final BezierMotion bezierMotion;

  /// Creates a [CardAnimationCalculator] with specified configuration.
  CardAnimationCalculator({
    required this.theme,
  }) : bezierMotion = BezierMotion(
          flightWidthFactor: theme.flightWidthFactor,
          bezierHeight: theme.bezierHeight,
        );

  /// Calculates the card transforms for a given continuous [scrollPosition].
  ///
  /// Returns a list of [CardTransform]s of length `visibleCount + 1`.
  ///
  /// The list of transforms corresponds to the cards in physical slot order:
  /// Slot 0 is the top card, Slot 1 is the second card, ..., Slot [visibleCount] is the bottom buffer card.
  List<CardTransform> calculateTransforms({
    required double scrollPosition,
    required double containerWidth,
  }) {
    final visibleCount = theme.visibleCount;
    final totalSlots = visibleCount + 1;

    // Find base integer index and the transition progression [0.0, 1.0)
    final floorIndex = scrollPosition.floor();
    final progress = scrollPosition - floorIndex;

    // 1. Compute the resting transforms for each slot
    final restingTransforms = List<CardTransform>.generate(totalSlots, (slot) {
      return _calculateRestingTransform(slot, visibleCount);
    });

    // 2. Compute the active transforms during transition
    final activeTransforms = List<CardTransform>.filled(
      totalSlots,
      const CardTransform.identity(),
    );

    // Card 0 (the top card) is flying out along the Bezier curve to the bottom slot (totalSlots - 1).
    final topStart = restingTransforms[0];
    final bottomDest = restingTransforms[totalSlots - 1];

    final flightOffset = bezierMotion.calculateFlightOffset(
      t: progress,
      start: topStart.offset,
      end: bottomDest.offset,
      containerWidth: containerWidth,
    );

    final flightRotation = bezierMotion.calculateFlightRotation(
      t: progress,
      maxRotation: theme.maxFlightRotation,
    );

    // Fade out as it flies away, and fade back in right as it docks to the bottom.
    // This makes the transition exceptionally smooth and visually striking.
    double flightOpacity;
    if (progress < 0.4) {
      // Fade out from 1.0 to 0.1
      flightOpacity = 1.0 - (progress / 0.4) * 0.9;
    } else if (progress < 0.8) {
      // Keep very low opacity during intermediate flight
      flightOpacity = 0.1;
    } else {
      // Fade back in to bottom resting opacity as it lands
      final fadeProgress = (progress - 0.8) / 0.2;
      flightOpacity = 0.1 + fadeProgress * (bottomDest.opacity - 0.1);
    }

    // Dynamic z-index depth sorting:
    // When the card is leaving the top of the stack, it must render on top of all other cards.
    // However, when it reaches the midpoint (progress > 0.4), it should dive UNDER the other cards
    // so it doesn't overlap them from above as it curves back into the bottom of the stack.
    final flightZIndex = progress < 0.45
        ? (visibleCount + 2.0)
        : (bottomDest.zIndex - 1.0);

    activeTransforms[0] = CardTransform(
      offset: flightOffset,
      scale: lerpDouble(topStart.scale, bottomDest.scale, progress) ?? bottomDest.scale,
      opacity: flightOpacity,
      rotation: flightRotation,
      zIndex: flightZIndex,
      elevation: lerpDouble(topStart.elevation, bottomDest.elevation, progress) ?? bottomDest.elevation,
    );

    // Card 1 to visibleCount are sliding up one level.
    // Card i interpolates from restingTransforms[i] to restingTransforms[i - 1].
    for (var i = 1; i < totalSlots; i++) {
      final start = restingTransforms[i];
      final target = restingTransforms[i - 1];

      activeTransforms[i] = CardTransform(
        offset: Offset.lerp(start.offset, target.offset, progress) ?? target.offset,
        scale: lerpDouble(start.scale, target.scale, progress) ?? target.scale,
        opacity: lerpDouble(start.opacity, target.opacity, progress) ?? target.opacity,
        // If there is layer-based rotation, interpolate it smoothly.
        rotation: lerpDouble(start.rotation, target.rotation, progress) ?? target.rotation,
        zIndex: lerpDouble(start.zIndex, target.zIndex, progress) ?? target.zIndex,
        elevation: lerpDouble(start.elevation, target.elevation, progress) ?? target.elevation,
      );
    }

    return activeTransforms;
  }

  /// Calculates the static resting transform of a card at a given slot.
  CardTransform _calculateRestingTransform(int slot, int visibleCount) {
    if (slot == visibleCount) {
      // Bottom buffer card is fully transparent and sits under the stack
      return CardTransform(
        offset: Offset(0.0, theme.spacing * visibleCount),
        scale: theme.minScale,
        opacity: 0.0,
        rotation: 0.0,
        zIndex: -1.0,
        elevation: 0.0,
      );
    }

    // Linearly calculate translation, scale, opacity, and zIndex for visible levels.
    final levelProgress = slot / (visibleCount - 1);

    final yOffset = theme.spacing * slot;
    final scale = 1.0 - (1.0 - theme.minScale) * levelProgress;
    final opacity = 1.0 - (1.0 - theme.minOpacity) * levelProgress;

    // Add minor alternating rotation to lower layers to give an expressive M3 look
    double rotation = 0.0;
    if (slot > 0 && theme.stackRotationStep != 0.0) {
      rotation = (slot % 2 == 0 ? 1 : -1) * slot * theme.stackRotationStep;
    }

    final zIndex = visibleCount.toDouble() - slot;
    final elevation = theme.maxElevation * (1.0 - levelProgress);

    return CardTransform(
      offset: Offset(0.0, yOffset),
      scale: scale,
      opacity: opacity.clamp(0.0, 1.0),
      rotation: rotation,
      zIndex: zIndex,
      elevation: elevation,
    );
  }
}
