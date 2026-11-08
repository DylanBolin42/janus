## 2026-09-17 - Icon Button Accessibility in Modal Sheet Navigation
经验心得： Custom icon-only buttons (such as `M3EIconButton` in modal sheet navigation bars) lack automatic accessibility labels and hover tooltips. Wrapping them in explicit `Semantics(label: ..., button: true)` and `Tooltip(message: ...)` guarantees proper screen reader announcements and desktop hover feedback without changing visual layout or styling.
后续行动： For all non-standard icon buttons across modal sheets and app bars, consistently apply `Semantics` and `Tooltip` wrappers.
