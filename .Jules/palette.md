# Palette's UX Journal

## 2025-02-15 - Glass Confirmation Pattern for Destructive Actions
**Learning:** In highly customized, immersive design languages (like liquid glassmorphism), standard platform-native alert dialogs break immersion and visual consistency. Destructive actions, such as database deletion, must use the custom design system's glass-morphic dialog overlay (`GlassDialog`) and provide fluid animated feedback (`GlassToast`) to reinforce safety while maintaining aesthetic continuity.
**Action:** Always prefer design-system-specific overlays like `GlassDialog` and `GlassToast` for warnings, alerts, and notifications on destructive or async actions rather than falling back to standard material or cupertino dialogs.
