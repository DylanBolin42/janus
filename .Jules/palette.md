# Palette's UX & Accessibility Journal

This file contains key learnings and best practices for user experience (UX) and accessibility (a11y) across the Janus workspace.

## 2025-02-12 - Custom Semantics and Isolated Scrolling Sub-lists
经验心得：
1. **自定义交互组件的无障碍支持 (Custom Interactive a11y)**:
   - 当在 Flutter 中使用 `GestureDetector` 和 `Container` 构建自定义交互式组件（如自定义 Checkbox 指示器）时，必须使用 `Semantics` 包裹并设置 `label`、`value`、`checked` 和 `button: true` 属性，以确保屏幕阅读器（如 TalkBack / VoiceOver）能够正确识别和播报其状态与作用。
2. **滚动区域嵌套与渲染性能 (Nested Scrolling Performance)**:
   - 在父级 `ListView` 中嵌套动态和频繁变化的子列表（如任务列表）时，应将子列表隔离在独立的 `ConsumerWidget` 组件中以避免全局页面重新构建。
   - 子滚动列表必须指定 `shrinkWrap: true` 和 `physics: const NeverScrollableScrollPhysics()`，以正确传递约束，防止视口布局异常（Viewport layout exceptions）。
后续行动：
- 在后续的任务卡片、多选组件或复杂表单开发中，严格遵守 `Semantics` 无障碍包装指南，确保所有手势元素均能被屏幕阅读器友好访问。
- 采用局部刷新组件隔离模式，避免对大型静态头部等非易变 UI 造成冗余渲染。
