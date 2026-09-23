## 2026-09-21 - Custom Checkbox Semantics in TaskCard
经验心得： Custom checkbox indicators built using GestureDetector and AnimatedContainer in TaskCard lack native accessibility semantics, making them invisible and unannounced to screen readers. Wrapping the indicator with a Semantics widget defining label, value, checked, and button: true exposes explicit accessibility traits to screen readers without modifying existing visual design or animations.
后续行动： Wrap any custom interactive toggle or checkbox widgets in the codebase with explicit Semantics attributes.
