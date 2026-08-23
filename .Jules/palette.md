## 2026-08-19 - Accessibility & Tooltips for Icon-only Navigation Buttons
经验心得： 在 Flutter 中，仅有 Icon 的按钮（如 CustomAppbar 的返回按钮、TaskCreationPage 的关闭与新增按钮）容易遗漏屏幕阅读器标签与悬停/长按提示。将 Icon 按钮包裹在 `Semantics(label: '...', button: true)` 和 `Tooltip(message: '...')` 下，可大幅提升无障碍体验（a11y）和桌面/长按交互体验。
后续行动： 未来构建仅图标按钮组件时，应确保同时传递 `tooltip` 与语义说明（`Semantics`）。
