import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ThresholdDivider — the signature visual element of the Janus inbox.
///
/// A horizontal rule with a warm glowing dot at its centre, resembling light
/// under a closed door. The section label is rendered as a "door plate" just
/// above the line. The [warmth] parameter controls how bright and warm the
/// glow appears — urgent sections burn hot, distant horizons fade to twilight.
///
/// This is the ONE memorable visual element on the page. Everything else is
/// kept quiet so this carries the identity.
/// ─────────────────────────────────────────────────────────────────────────────
class ThresholdDivider extends StatelessWidget {
  const ThresholdDivider({
    required this.label,
    this.warmth = 0.6,
    this.count,
    super.key,
  });

  /// Section label shown above the line (e.g. "紧急 · 此刻").
  final String label;

  /// Warmth factor 0.0–1.0.
  ///
  /// 1.0 = full primary glow (urgent / now).
  /// 0.0 = baseline outline colour (distant horizon).
  final double warmth;

  /// Optional count badge (e.g. "3 项").
  final int? count;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Interpolate line + glow colour between primary (warm) and outline (cool).
    final Color glowColor = Color.lerp(cs.outline, cs.primary, warmth)!;
    final double glowOpacity = 0.15 + 0.55 * warmth; // 0.15 → 0.70
    final double glowScale = 0.6 + 1.4 * warmth; // small at 0, large at 1

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Label row (door plate) ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Text(
                  label,
                  style: tt.labelLarge?.copyWith(
                    color: glowColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                if (count != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: glowColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$count',
                      style: tt.labelSmall?.copyWith(
                        color: glowColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── The threshold line with central glow ──────────────────────────
          SizedBox(
            height: 4, // enough room for the glow dot
            child: Stack(
              children: [
                // Base line
                Positioned(
                  left: 0,
                  right: 0,
                  top: 1.5,
                  child: Container(
                    height: 1,
                    color: cs.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),

                // Central glow — a warm dot that pulses like light under a door
                Center(
                  child: Container(
                    width: 12 * glowScale,
                    height: 4,
                    decoration: BoxDecoration(
                      color: glowColor.withValues(alpha: glowOpacity),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        if (warmth > 0.3)
                          BoxShadow(
                            color: glowColor.withValues(alpha: glowOpacity * 0.5),
                            blurRadius: 6 * glowScale,
                            spreadRadius: 2 * glowScale,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
