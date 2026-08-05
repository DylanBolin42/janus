## 2025-08-05 - 修复收件箱任务列表渲染与多维度无障碍/UX打磨

经验心得：
1. **嵌套滚动视图的约束传递问题**：在 Flutter 中将基于 `ListView` 的自定义弹性卡片列表（如 `M3EDismissibleCardList`）作为子项嵌套到主页的滚动视图（`ListView`）时，若未显式指定 `shrinkWrap: true` 与 `physics: const NeverScrollableScrollPhysics()`，将导致子级 Viewport 抛出“垂直 Viewport 被给予了无限高度”的布局异常，从而发生 Null 指针或运行崩溃。通过此优化，组件得以正确自适应子项高度并随父容器无缝滚动，用户体验得以完美闭环。
2. **自定义交互组件的无障碍补丁**：项目中大量使用由 `GestureDetector` 与 `Container` 自定义的图标型复选框（Checkbox），这类组件由于缺乏语义化层级结构，屏幕阅读器完全无法识别和播报其交互意图。通过将其嵌套在 `Semantics` 容器中并声明 `label: '标记完成'`、`checked` 与 `button: true`，大幅增强了屏幕阅读器的兼容性。
3. **滑消动画与数据流状态重载优化**：接入 Riverpod state 后，将滑动删除（onDismiss）与勾选状态更新（onToggle）与全局 UI 数据流闭环绑定，配合精致的空状态插画，极大地满足了用户删除任务、勾选任务后的瞬间反馈感与掌控感。

后续行动：
1. 未来在开发涉及滚动容器嵌套的列表式卡片组件时，一律默认添加 `shrinkWrap` 和 `physics` 限制，消除潜在的 Viewport 约束问题。
2. 任何通过 GestureDetector 手势伪造的按钮、开关、复选框等交互组件，必须配合 Flutter `Semantics` 语义化标签进行封装，保障无障碍性（Accessibility）这一底线要求。
