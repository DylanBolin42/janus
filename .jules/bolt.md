# Bolt's Performance Journal ⚡

## 2026-08-12 - [InboxPage Task List Isolated Rendering & Layout Constraints] **经验心得：** [在 Flutter 应用中，将频繁变动的列表（如首页根据分类切换渲染的任务卡片）从包含静态大图和复杂文字效果的父级组件中隔离出来至独立的 `ConsumerWidget` （如 `_InboxTaskList`），可以避免不必要的父组件重绘（Repaint / Rebuild），从而极大地优化渲染性能与帧率。同时，当在父级 `ListView` 中嵌套动态列表时，必须设置 `shrinkWrap: true` 和 `physics: const NeverScrollableScrollPhysics()` 以防止 viewport 布局冲突。] **后续行动：** [未来开发类似包含复杂头部和切换项的页面时，应始终将动态列表和切换卡片隔离到专有的小型 Widget 中，并严格遵循嵌套 Scrollable 组件的约束规则。]
