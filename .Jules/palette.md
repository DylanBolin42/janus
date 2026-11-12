## 2025-05-18 - 图标按钮无障碍与 Hover 提示增强
经验心得： Flutter 中的图标按钮（如 GlassIconButton 或 M3EIconButton）若未配备辅助说明，屏幕阅读器无法播放其含义，桌面/Web 端也缺少悬停提示。使用 Tooltip 包裹可同时补齐微视觉反馈与屏幕阅读器 a11y 标签。
后续行动： 在新增图标按钮时优先添加 Tooltip 或 Semantics 描述，提升跨端操作可读性。
