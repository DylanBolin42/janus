import 'package:flutter/material.dart';
import 'package:janus/models/task.dart';

/// 首页轮播的三种模式（有序循环）。
///
/// 供 [inbox_page.dart] 的模式切换与任务列表按模式取值使用。
const List<String> inboxModes = ['EMERGENCY', 'PLANNED', 'COMING'];

/// 生成三种模式的 mock 任务数据。
///
/// 返回 `{模式名: 任务列表}` 映射，模式名与 [inboxModes] 保持一致。
/// 截止时间基于调用时刻的相对偏移，模拟真实的剩余时间观感。
///
/// TODO: 后续替换为数据库（drift）真实查询。
Map<String, List<Task>> buildInboxMockData() {
  final now = DateTime.now();
  return {
    'EMERGENCY': [
      Task(
        id: 'emg-01',
        title: '修复登录页闪退',
        description: 'Android 端快速登录偶发崩溃，需尽快定位修复',
        priority: '紧急',
        ddl: now.add(const Duration(hours: 2, minutes: 45)),
        est: const TimeOfDay(hour: 2, minute: 0),
      ),
      Task(
        id: 'emg-02',
        title: '回复客户加急邮件',
        description: '大客户合同细节待确认，今天下班前必须回复',
        priority: '高',
        ddl: now.add(const Duration(hours: 4)),
        est: const TimeOfDay(hour: 1, minute: 0),
      ),
      Task(
        id: 'emg-03',
        title: '上线支付网关补丁',
        description: '安全团队发现的漏洞补丁，需紧急发版',
        priority: '紧急',
        ddl: now.add(const Duration(hours: 1, minutes: 30)),
        est: const TimeOfDay(hour: 1, minute: 30),
      ),
    ],
    'PLANNED': [
      Task(
        id: 'pln-01',
        title: '整理 Q3 需求文档',
        description: '汇总产品、设计、研发三方需求并输出评审稿',
        priority: '高',
        ddl: DateTime(
          now.year,
          now.month,
          now.day,
        ).add(const Duration(days: 1, hours: 14)),
        est: const TimeOfDay(hour: 3, minute: 0),
      ),
      Task(
        id: 'pln-02',
        title: '设计系统组件评审',
        description: '新组件规范与现有主题对齐情况检查',
        priority: '中',
        ddl: DateTime(
          now.year,
          now.month,
          now.day,
        ).add(const Duration(days: 1, hours: 10)),
        est: const TimeOfDay(hour: 2, minute: 0),
      ),
      Task(
        id: 'pln-03',
        title: '准备团队周会',
        description: '梳理本周进展、风险与下周计划',
        priority: '中',
        ddl: now.add(const Duration(days: 1, hours: 18)),
        est: const TimeOfDay(hour: 1, minute: 0),
      ),
    ],
    'COMING': [
      Task(
        id: 'cmi-01',
        title: '年度技术分享 PPT',
        description: '主题：移动端性能优化实践',
        priority: '中',
        ddl: now.add(const Duration(days: 6)),
        est: const TimeOfDay(hour: 4, minute: 0),
      ),
      Task(
        id: 'cmi-02',
        title: '城市马拉松报名',
        description: '半程马拉松，记得提前准备体检报告',
        priority: '低',
        ddl: now.add(const Duration(days: 9)),
        est: const TimeOfDay(hour: 0, minute: 30),
      ),
      Task(
        id: 'cmi-03',
        title: '规划年末旅行',
        description: '目的地候选：云南 / 川西 / 北海道',
        priority: '低',
        ddl: now.add(const Duration(days: 12)),
        est: const TimeOfDay(hour: 3, minute: 0),
      ),
    ],
  };
}
