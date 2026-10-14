## 2025-02-23 - Icon-Only Button Accessibility Tooltips
经验心得： 在 Flutter 中，极简图标按钮（如 CustomAppbar 中的返回按钮、ModalSheet 头部关闭/提交按钮）在缺少显式 semantics/tooltip 时对屏幕阅读器（TalkBack/VoiceOver）及桌面端鼠标悬停缺乏足够可读性。通过统一包裹 Tooltip 并在 message 中指明动作（如 "返回", "关闭", "创建任务"），可兼顾桌面 Hover 交互提示与移动端屏幕阅读器朗读（a11y）。
后续行动： 在后续新增或重构带有图标操作按键（Icon-only Action Buttons）的页面组件时，确保一律增加 Tooltip 或 Semantics 声明。
