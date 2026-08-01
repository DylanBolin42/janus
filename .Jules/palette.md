# Palette's Journal

## 2026-08-01 - [Standardizing Interactive Icon Buttons & Destructive Actions]
**Learning:**
1. In Flutter apps utilizing custom styling (such as glassmorphism), standard icon-only buttons (`GlassIconButton`) lack native descriptive labels or tooltips, which hurts screen reader accessibility (ARIA/A11y equivalent) and desktop hover discoverability. Wrapping them in a native `Tooltip` instantly enhances both screen reader spoken labels and desktop visual discoverability.
2. Highly destructive actions, like database resetting, should always be gated by high-fidelity modal confirmation dialogs matching the app's visual style. Using `GlassDialog.show` from the `liquid_glass_widgets` package ensures visual consistency while preventing catastrophic user accidents. Following up with a dismissible `GlassToast` provides clear feedback on success.

**Action:**
- Always wrap icon-only buttons in `Tooltip` with concise, descriptive text.
- Standardize dangerous actions by utilizing `GlassDialog` gated confirms paired with `GlassToast` notifications.
