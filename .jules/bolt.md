## 2025-09-02 - Memoize M3EThemeData in m3eThemeBridgeBuilder

**经验心得：** `m3eThemeBridgeBuilder` 挂载在 `MaterialApp.builder` 层级，每次根级或 Overlay 重建时均会触发。原实现每次直接调用 `buildM3EThemeData(Theme.of(context))`，造成 `M3EThemeData`、`M3EColorScheme` 和 `mui.TextTheme` 的冗余实例创建。使用 `StatefulWidget` 缓存 `M3EThemeData` 并仅在 `ThemeData` 改变时重建，在不改变应用功能前提下避免了无谓的 GC 压力与 CPU 消耗。

**后续行动：** 在处理挂载于顶级 Builder / Provider 的桥接转换组件时，务必注意入参到转换结果的缓存/记忆化处理。
