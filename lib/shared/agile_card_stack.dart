import 'dart:math' as math;

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
//  Types
// ---------------------------------------------------------------------------

/// 8 trigger positions: 4 corners + 4 edge midpoints.
enum TriggerPosition {
  topLeft,
  topCenter,
  topRight,
  leftCenter,
  rightCenter,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

// ---------------------------------------------------------------------------
//  Internal helpers
// ---------------------------------------------------------------------------

/// Pre-generated random visual state for one card (offset + rotation).
class _CardVisualState {
  const _CardVisualState({
    required this.offsetX,
    required this.offsetY,
    required this.rotationDeg,
  });

  final double offsetX;
  final double offsetY;
  final double rotationDeg;
}

/// Widget phase.
enum _Phase { idle, dragging, returningToTop, centeringNewTop }

/// Holds positioned card layout data used during build.
class _CardPositioned {
  const _CardPositioned({
    required this.offset,
    required this.rotation,
    required this.opacity,
    required this.cardWidth,
    required this.cardHeight,
    required this.child,
  });

  final Offset offset;
  final double rotation;
  final double opacity;
  final double cardWidth;
  final double cardHeight;
  final Widget child;
}

// ---------------------------------------------------------------------------
//  AgileCardStack widget
// ---------------------------------------------------------------------------

/// A stack of cards with natural visual spread, top-card drag, animated
/// snap-back, and configurable screen-edge trigger zones.
///
/// Place this inside a [Stack] so it can move freely.  The widget fills its
/// available space and centers the deck within it.
class AgileCardStack extends StatefulWidget {
  const AgileCardStack({
    required this.children,
    this.cardSize = const Size(340, 160),
    this.triggerCallbacks = const {},
    this.zoneSizeFraction = 0.18,
    this.maxVisibleCards = 4,
    super.key,
  });

  /// Card widgets in display order (index 0 = topmost).
  final List<Widget> children;

  /// Size each card should be rendered at.
  final Size cardSize;

  /// Optional callbacks for trigger zones.  Keys present in this map are
  /// active; the card stack fires the callback when released inside that zone.
  final Map<TriggerPosition, VoidCallback> triggerCallbacks;

  /// Fraction of screen width/height that defines each trigger-zone's size.
  /// 0.18 means each corner/edge zone covers 18 % of the adjacent edges.
  final double zoneSizeFraction;

  /// How many cards are visible in the stack (capped internally by list length).
  final int maxVisibleCards;

  @override
  State<AgileCardStack> createState() => _AgileCardStackState();
}

class _AgileCardStackState extends State<AgileCardStack>
    with TickerProviderStateMixin {
  // -----------------------------------------------------------------------
  //  Constants
  // -----------------------------------------------------------------------
  static const double _amplification = 4.0; // lower-card drag multiplier
  static const double _maxDragDistance = 220.0;
  static const double _maxLowerOffset = 16.0; // px
  static const double _maxLowerAngle = 5.0; // degrees
  static const double _releaseThreshold = 80.0; // px radius for snap-back zone

  /// Soft‑clamp [offset]’s magnitude so that values ≤ 75 % of [limit] pass
  /// linearly; beyond that they approach [limit] asymptotically (no hard wall).
  static Offset _softClampOffset(Offset offset, double limit) {
    final double mag = offset.distance;
    if (mag < 1e-6) return offset;
    const double k = 0.75;
    if (mag <= limit * k) return offset;
    final double tail = (mag - limit * k) / (limit * (1.0 - k));
    final double softTail = limit * (1.0 - k) * (1.0 - math.exp(-tail));
    return offset / mag * (limit * k + softTail);
  }

  // -----------------------------------------------------------------------
  //  Card data (order / visuals)
  // -----------------------------------------------------------------------
  late List<int> _cardOrder; // indices into widget.children
  late List<_CardVisualState> _visualStates;
  int get _visibleCount =>
      widget.children.length.clamp(0, widget.maxVisibleCards);

  // -----------------------------------------------------------------------
  //  Phase & drag state
  // -----------------------------------------------------------------------
  _Phase _phase = _Phase.idle;
  Offset _topCardOffset = Offset.zero; // net drag offset from rest centre
  bool _hasMoved = false; // true once onPanUpdate fires (tap guard)

  // Per‑card influence (computed in _updateLowerCardInfluences)
  final List<Offset> _lowerOffsets = List.filled(4, Offset.zero);
  final List<double> _lowerAngles = List.filled(4, 0.0);

  // -----------------------------------------------------------------------
  //  Animation state
  // -----------------------------------------------------------------------
  AnimationController? _animController;
  CurvedAnimation? _curvedAnim;
  Animation<Offset>? _posAnim;
  Animation<double>? _rotAnim;

  // -----------------------------------------------------------------------
  //  Initialisation
  // -----------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _initStack();
  }

  void _initStack() {
    final rng = math.Random();
    _cardOrder = List.generate(widget.children.length, (i) => i);
    _visualStates = List.generate(
      widget.children.length,
      (_) => _CardVisualState(
        offsetX: (rng.nextDouble() - 0.5) * 12.0, // -6 .. +6 px
        offsetY: (rng.nextDouble() - 0.5) * 12.0,
        rotationDeg: (rng.nextDouble() - 0.5) * 10.0, // -5 .. +5 °
      ),
    );
    _topCardOffset = Offset.zero;
    _phase = _Phase.idle;
  }

  @override
  void dispose() {
    _curvedAnim?.dispose();
    _animController?.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------------------
  //  didUpdateWidget
  // -----------------------------------------------------------------------
  @override
  void didUpdateWidget(AgileCardStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children.length != oldWidget.children.length) {
      _curvedAnim?.dispose();
      _curvedAnim = null;
      _animController?.stop();
      _animController?.dispose();
      _animController = null;
      _phase = _Phase.idle;
      _initStack();
    }
  }

  // -----------------------------------------------------------------------
  //  Build
  // -----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final visible = _visibleCount;
    if (visible == 0) return const SizedBox.shrink();

    final List<_CardPositioned> stackChildren = [];

    // Build from bottom-most (last visible) to top-most (first visible).
    for (int depth = visible - 1; depth >= 0; depth--) {
      final int cardIdx = _cardOrder[depth];
      final vs = _visualStates[cardIdx];

      Offset baseOffset;
      double baseRotation;
      double opacity;

      if (depth == 0) {
        // Top card – always centered and level except during drag/animation.
        if (_phase == _Phase.dragging) {
          baseOffset = _topCardOffset;
          baseRotation = 0.0;
        } else if (_phase == _Phase.returningToTop ||
            _phase == _Phase.centeringNewTop) {
          baseOffset = _posAnim!.value;
          baseRotation = _rotAnim!.value;
        } else {
          baseOffset = Offset.zero;
          baseRotation = 0.0;
        }
        opacity = 1.0;
      } else {
        // Lower card – has its rest offset + drag influence.
        final int lowerIdx = depth - 1; // 0‑based index into _lowerOffsets
        baseOffset =
            Offset(vs.offsetX, vs.offsetY) +
            (lowerIdx < _lowerOffsets.length
                ? _lowerOffsets[lowerIdx]
                : Offset.zero);
        baseRotation =
            vs.rotationDeg +
            (lowerIdx < _lowerAngles.length ? _lowerAngles[lowerIdx] : 0.0);
        opacity = _opacityForDepth(depth);
      }

      stackChildren.add(
        _CardPositioned(
          offset: baseOffset,
          rotation: baseRotation * math.pi / 180.0,
          opacity: opacity,
          cardWidth: widget.cardSize.width,
          cardHeight: widget.cardSize.height,
          child: widget.children[cardIdx],
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: SizedBox.expand(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double cx = constraints.maxWidth / 2;
            final double cy = constraints.maxHeight / 2;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                for (final card in stackChildren)
                  Positioned(
                    left: cx + card.offset.dx - card.cardWidth / 2,
                    top: cy + card.offset.dy - card.cardHeight / 2,
                    child: Transform.rotate(
                      angle: card.rotation,
                      child: Opacity(
                        opacity: card.opacity,
                        child: SizedBox(
                          width: card.cardWidth,
                          height: card.cardHeight,
                          child: card.child,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  //  Opacity helper
  // -----------------------------------------------------------------------
  double _opacityForDepth(int depth) {
    // depth 0 = top card; each deeper layer loses 15 % opacity.
    if (depth <= 0) return 1.0;
    return (1.0 - depth * 0.15).clamp(0.3, 1.0);
  }

  // -----------------------------------------------------------------------
  //  Gesture handlers
  // -----------------------------------------------------------------------
  void _onPanStart(DragStartDetails details) {
    // Interrupt any running animation and capture current position.
    if (_animController != null && _animController!.isAnimating) {
      _topCardOffset = _posAnim!.value;
      _curvedAnim?.dispose();
      _curvedAnim = null;
      _animController!.stop();
      _animController!.dispose();
      _animController = null;
    }
    _phase = _Phase.dragging;
    _hasMoved = false;
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_phase != _Phase.dragging) return;
    _hasMoved = true;
    _topCardOffset += details.delta;
    _updateLowerCardInfluences();
    setState(() {});
  }

  void _onPanEnd(DragEndDetails details) {
    if (_phase != _Phase.dragging) return;
    _phase = _Phase.idle;

    // Tap without drag → do nothing.
    if (!_hasMoved) {
      setState(() {});
      return;
    }

    // --- check trigger zones ------------------------------------------------
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      final Size ourSize = box.size;
      final Offset deckCentre = Offset(ourSize.width / 2, ourSize.height / 2);
      final Offset cardLocal = deckCentre + _topCardOffset;
      final Offset cardGlobal = box.localToGlobal(cardLocal);
      final Size screen = MediaQuery.of(context).size;

      final TriggerPosition? zone = _findTriggerZone(cardGlobal, screen);
      if (zone != null && widget.triggerCallbacks.containsKey(zone)) {
        widget.triggerCallbacks[zone]!();
        _topCardOffset = Offset.zero;
        _cycleCards();
        setState(() {});
        return;
      }
    }

    // --- circular release zone ----------------------------------------------
    if (_topCardOffset.distance < _releaseThreshold) {
      // Inside the circle → return to top (no cycle).
      _startReturnToTop();
    } else {
      // Outside the circle → cycle to bottom with centering animation.
      _startCycleNewTop();
    }
  }

  // -----------------------------------------------------------------------
  //  Lower-card influence (gravity‑based, computed each frame during drag)
  // -----------------------------------------------------------------------
  void _updateLowerCardInfluences() {
    final double dragMag = _topCardOffset.distance;
    if (dragMag < 0.5) {
      for (int i = 0; i < _lowerOffsets.length; i++) {
        _lowerOffsets[i] = Offset.zero;
        _lowerAngles[i] = 0.0;
      }
      return;
    }

    // Normalised drag magnitude [0..1].
    final double t = (dragMag / _maxDragDistance).clamp(0.0, 1.0);

    final int maxDepth = (_visibleCount - 1).clamp(0, _lowerOffsets.length);
    for (int d = 0; d < maxDepth; d++) {
      // 1‑indexed depth for the formula.
      final double depth = (d + 1).toDouble();

      // Effective amplification at this depth (1/r² decay).
      // A / (depth+1)² gives ~1.0, 0.44, 0.25, 0.16 for depths 1‑4.
      final double aEff = _amplification / ((depth + 1.0) * (depth + 1.0));

      // Equilibrium deflection ratio: aEff / (1 + aEff).
      final double eqRatio = aEff / (1.0 + aEff); // 0.5, 0.31, 0.20, 0.14

      // Nonlinear approach to the 16 px / 5° bound.
      // exp approach gives a smooth asymptotic feel (stiffer near limit).
      final double raw = (t * eqRatio * 4.0).clamp(0.0, 8.0);
      final double approach = 1.0 - math.exp(-raw);

      _lowerOffsets[d] = _topCardOffset * approach;

      // Soft clamp: linearly below 75% of limit, then asymptotic approach.
      _lowerOffsets[d] = _softClampOffset(_lowerOffsets[d], _maxLowerOffset);

      // Angular influence: rotate card in the plane toward the drag direction.
      // Performance optimization: reuse normalized drag magnitude `t` directly.
      _lowerAngles[d] = t * eqRatio * _maxLowerAngle;
    }

    // Clear remaining slots.
    for (int i = maxDepth; i < _lowerOffsets.length; i++) {
      _lowerOffsets[i] = Offset.zero;
      _lowerAngles[i] = 0.0;
    }
  }

  // -----------------------------------------------------------------------
  //  Trigger zone detection
  // -----------------------------------------------------------------------
  TriggerPosition? _findTriggerZone(Offset globalPos, Size screen) {
    final double t = widget.zoneSizeFraction;

    final double w = screen.width;
    final double h = screen.height;

    // Corners (highest priority – check first).
    if (_pointInRect(globalPos, 0, 0, w * t, h * t)) {
      return TriggerPosition.topLeft;
    }
    if (_pointInRect(globalPos, w * (1.0 - t), 0, w, h * t)) {
      return TriggerPosition.topRight;
    }
    if (_pointInRect(globalPos, 0, h * (1.0 - t), w * t, h)) {
      return TriggerPosition.bottomLeft;
    }
    if (_pointInRect(globalPos, w * (1.0 - t), h * (1.0 - t), w, h)) {
      return TriggerPosition.bottomRight;
    }

    // Edge midpoints.
    if (_pointInRect(globalPos, w * 0.41, 0, w * 0.59, h * t)) {
      return TriggerPosition.topCenter;
    }
    if (_pointInRect(globalPos, w * 0.41, h * (1.0 - t), w * 0.59, h)) {
      return TriggerPosition.bottomCenter;
    }
    if (_pointInRect(globalPos, 0, h * 0.41, w * t, h * 0.59)) {
      return TriggerPosition.leftCenter;
    }
    if (_pointInRect(globalPos, w * (1.0 - t), h * 0.41, w, h * 0.59)) {
      return TriggerPosition.rightCenter;
    }

    return null;
  }

  bool _pointInRect(Offset p, double l, double t, double r, double b) {
    return p.dx >= l && p.dx <= r && p.dy >= t && p.dy <= b;
  }

  // -----------------------------------------------------------------------
  //  Snap-back animation (inside circle → return to top)
  // -----------------------------------------------------------------------
  void _startReturnToTop() {
    final Offset startOffset = _topCardOffset;

    _phase = _Phase.returningToTop;
    _setupAnimation(
      startOffset: startOffset,
      startRotation: 0.0,
      duration: Duration(
        milliseconds: (startOffset.distance / _releaseThreshold * 1000)
            .clamp(400, 1000)
            .toInt(),
      ),
      curve: Curves.easeOutCubic,
      onComplete: _onReturnToTopComplete,
      onTick: () {
        // Keep lower influences in sync so they smoothly return to rest too.
        _topCardOffset = _posAnim!.value;
        _updateLowerCardInfluences();
      },
    );
    _animController!.forward();
    setState(() {});
  }

  void _onReturnToTopComplete() {
    _curvedAnim?.dispose();
    _curvedAnim = null;
    _animController?.dispose();
    _animController = null;
    _posAnim = null;
    _rotAnim = null;
    _topCardOffset = Offset.zero;
    _phase = _Phase.idle;
    if (mounted) setState(() {});
  }

  // -----------------------------------------------------------------------
  //  Cycle animation (outside circle → cycle, animate new top card)
  // -----------------------------------------------------------------------
  void _startCycleNewTop() {
    if (widget.children.length <= 1) {
      // Single card — nothing to cycle; return to top instead.
      _startReturnToTop();
      return;
    }
    // Capture the new top card's current visual state BEFORE cycling.
    // It's currently at depth 1 (second card) in the stack.
    final int newTopIdx = _cardOrder[1];
    final vs = _visualStates[newTopIdx];
    final Offset startOffset =
        Offset(vs.offsetX, vs.offsetY) + _lowerOffsets[0];
    final double startRotation = vs.rotationDeg + _lowerAngles[0];

    // Reset lower card influences.
    for (int i = 0; i < _lowerOffsets.length; i++) {
      _lowerOffsets[i] = Offset.zero;
      _lowerAngles[i] = 0.0;
    }

    _topCardOffset = Offset.zero;
    _cycleCards();

    _phase = _Phase.centeringNewTop;
    _setupAnimation(
      startOffset: startOffset,
      startRotation: startRotation,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      onComplete: _onCenterNewTopComplete,
    );
    _animController!.forward();
    setState(() {});
  }

  void _onCenterNewTopComplete() {
    _curvedAnim?.dispose();
    _curvedAnim = null;
    _animController?.dispose();
    _animController = null;
    _posAnim = null;
    _rotAnim = null;
    _phase = _Phase.idle;
    if (mounted) setState(() {});
  }

  // -----------------------------------------------------------------------
  //  Animation helper
  // -----------------------------------------------------------------------
  void _setupAnimation({
    required Offset startOffset,
    required double startRotation,
    required Duration duration,
    required Curve curve,
    required VoidCallback onComplete,
    VoidCallback? onTick,
  }) {
    _curvedAnim?.dispose();
    _animController?.dispose();
    _animController = AnimationController(vsync: this, duration: duration);

    _curvedAnim = CurvedAnimation(parent: _animController!, curve: curve);

    _posAnim = Tween<Offset>(
      begin: startOffset,
      end: Offset.zero,
    ).animate(_curvedAnim!);

    _rotAnim = Tween<double>(
      begin: startRotation,
      end: 0.0,
    ).animate(_curvedAnim!);

    _animController!.addListener(() {
      if (onTick != null) onTick();
      setState(() {});
    });

    _animController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onComplete();
      }
    });
  }

  // -----------------------------------------------------------------------
  //  Card cycling
  // -----------------------------------------------------------------------
  void _cycleCards() {
    if (widget.children.length <= 1) return;
    final int first = _cardOrder.removeAt(0);
    _cardOrder.add(first);
    // _visualStates is indexed by card identity (matching widget.children),
    // NOT by deck position — never cycle it.  Each card keeps its own
    // random visual state across position changes.
  }
}
