import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/pages/Inbox/inbox_page.dart';

void main() {
  Future<void> pumpInbox(WidgetTester tester) async {
    // 足够高的视口，确保任务卡片区域可见
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: InboxPage())),
    );
    await tester.pump();
  }

  /// 点击右侧箭头切换到下一个模式
  Future<void> nextMode(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.keyboard_arrow_right_rounded));
    await tester.pumpAndSettle();
  }

  testWidgets('InboxPage 渲染首页标题', (tester) async {
    await pumpInbox(tester);

    expect(find.text('GOOD MORNING'), findsOneWidget);
    expect(find.text('BRO'), findsOneWidget);
  });

  testWidgets('默认显示 EMERGENCY 模式任务', (tester) async {
    await pumpInbox(tester);

    expect(find.text('修复登录页闪退'), findsOneWidget);
    expect(find.text('上线支付网关补丁'), findsOneWidget);
    // 不应显示其他模式的任务
    expect(find.text('整理 Q3 需求文档'), findsNothing);
  });

  testWidgets('切换到 PLANNED 模式显示计划任务', (tester) async {
    await pumpInbox(tester);

    await nextMode(tester);

    expect(find.text('整理 Q3 需求文档'), findsOneWidget);
    expect(find.text('准备团队周会'), findsOneWidget);
    expect(find.text('修复登录页闪退'), findsNothing);
  });

  testWidgets('切换到 COMING 模式显示即将到来任务', (tester) async {
    await pumpInbox(tester);

    await nextMode(tester);
    await nextMode(tester);

    expect(find.text('年度技术分享 PPT'), findsOneWidget);
    expect(find.text('规划年末旅行'), findsOneWidget);
    expect(find.text('整理 Q3 需求文档'), findsNothing);
  });
}
