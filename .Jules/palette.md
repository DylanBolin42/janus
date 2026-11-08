# Palette Journal

## 2026-03-31 - Custom Checkbox Semantics and Tooltip Overlay Patterns
经验心得： 在 Flutter 中，通过 GestureDetector 和 Container 构建的自定义 Checkbox 默认不具备任何屏幕阅读器可读属性。如果不显示声明 `Semantics(label, value, checked, button)`，TalkBack 与 VoiceOver 会完全忽略其交互状态。此外，针对全图标按钮（如 M3EIconButton / GlassIconButton），统一外包裹 `Tooltip` 既能提升桌面端的悬停提示体验，又能为移动端无障碍套件自动注入语义属性。
后续行动： 凡在此 codebase 中定义非原生 UI 控件（如自定义 Checkbox、Radio 或 Toggle 卡片）时，必须以 `Semantics` 包裹并配置 `label`、`value` 及 `checked`；全图标按钮一律包裹 `Tooltip` 提供显式文字说明。
