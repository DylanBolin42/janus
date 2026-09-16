# Bolt Journal ⚡

## 2026-09-16 - Granular Riverpod `.select()` watching in Sub-Setting Pages **经验心得：** 在 Settings 界面各个子页面中，如果直接使用 `ref.watch(appSettingsProvider)` 监听整个 `AppSettings` 对象，任何设置的改变（例如修改 AI 接口地址或切换显示模式）都会触发所有已打开 Settings 子页面的重新构建（rebuild）。而通过使用 `ref.watch(appSettingsProvider.select(...))` 只监听子页面实际依赖的具体字段，能够在设置字段更新时仅重绘关心该字段的页面，避免无谓的全页重新构建。 **后续行动：** 在后续新增 Riverpod ConsumerWidget 或 Setting 页面时，优先使用 `.select()` 提取所需属性，减少全量 Model 监听引起的性能损耗。
