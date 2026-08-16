import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/pages/InboxPage/inbox_page.dart';

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
    // M3EButtonGroup 会渲染两份箭头图标（动画层），点第一份即可
    await tester.tap(find.byIcon(Icons.keyboard_arrow_right_rounded).first);
    await tester.pumpAndSettle();
  }

  testWidgets('InboxPage 渲染首页标题', (tester) async {
    await pumpInbox(tester);

    expect(find.text('GOOD MORNING'), findsOneWidget);
    expect(find.text('BRO'), findsOneWidget);
  });

  // ReelText 将模式标签拆成单字符 Text（滚动动画），故用模式特有字符断言当前模式。
  // 每份 reel 文本渲染两份副本（滚动用）。

  testWidgets('默认显示 EMERGENCY 模式（空任务列表）', (tester) async {
    await pumpInbox(tester);

    // 'Y' 是 EMERGENCY 特有字符（reel 两份副本）
    expect(find.text('Y'), findsNWidgets(2));
    // 任务列表尚未接入数据库，不渲染 mock 任务
    expect(find.text('修复登录页闪退'), findsNothing);
  });

  testWidgets('切换到 PLANNED 模式', (tester) async {
    await pumpInbox(tester);

    await nextMode(tester);

    // EMERGENCY 字符消失，'P' 是 PLANNED 特有字符（两份）
    expect(find.text('Y'), findsNothing);
    expect(find.text('P'), findsNWidgets(2));
    expect(find.text('修复登录页闪退'), findsNothing);
  });

  testWidgets('切换到 COMING 模式', (tester) async {
    await pumpInbox(tester);

    await nextMode(tester);
    await nextMode(tester);

    // PLANNED 字符消失，页面正常渲染
    expect(find.text('P'), findsNothing);
    expect(find.text('GOOD MORNING'), findsOneWidget);
    expect(find.text('修复登录页闪退'), findsNothing);
  });
}
