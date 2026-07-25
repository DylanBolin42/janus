import 'dart:ui';
import 'package:flutter/widgets.dart';

/// A class representing the visual transformation properties of a single card
/// in the infinite card stack.
///
/// Contains translation offset, scale, opacity, rotation, z-index and elevation.
@immutable
class CardTransform {
  /// The horizontal and vertical translation offset of the card.
  final Offset offset;

  /// The scale factor of the card (typically between 0.0 and 1.0).
  final double scale;

  /// The opacity of the card (between 0.0 and 1.0).
  final double opacity;

  /// The rotation angle of the card in radians.
  final double rotation;

  /// The rendering depth/paint order. Cards with higher zIndex are painted
  /// on top of cards with lower zIndex.
  final double zIndex;

  /// The visual shadow elevation of the card.
  final double elevation;

  /// Creates a [CardTransform] with the specified transformation properties.
  const CardTransform({
    required this.offset,
    required this.scale,
    required this.opacity,
    required this.rotation,
    required this.zIndex,
    required this.elevation,
  });

  /// The default/identity card transform representing a pristine top card.
  const CardTransform.identity()
      : offset = Offset.zero,
        scale = 1.0,
        opacity = 1.0,
        rotation = 0.0,
        zIndex = 1.0,
        elevation = 0.0;

  /// Linearly interpolates between this [CardTransform] and another [CardTransform].
  ///
  /// This is optimized for smooth, continuous rendering during drag gestures
  /// and automated transitions.
  CardTransform lerpTo(CardTransform other, double t) {
    return CardTransform(
      offset: Offset.lerp(offset, other.offset, t) ?? other.offset,
      scale: lerpDouble(scale, other.scale, t) ?? other.scale,
      opacity: lerpDouble(opacity, other.opacity, t) ?? other.opacity,
      rotation: lerpDouble(rotation, other.rotation, t) ?? other.rotation,
      zIndex: lerpDouble(zIndex, other.zIndex, t) ?? other.zIndex,
      elevation: lerpDouble(elevation, other.elevation, t) ?? other.elevation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CardTransform &&
        other.offset == offset &&
        other.scale == scale &&
        other.opacity == opacity &&
        other.rotation == rotation &&
        other.zIndex == zIndex &&
        other.elevation == elevation;
  }

  @override
  int get hashCode => Object.hash(
        offset,
        scale,
        opacity,
        rotation,
        zIndex,
        elevation,
      );

  @override
  String toString() {
    return 'CardTransform(offset: $offset, scale: $scale, opacity: $opacity, '
        'rotation: $rotation, zIndex: $zIndex, elevation: $elevation)';
  }
}
