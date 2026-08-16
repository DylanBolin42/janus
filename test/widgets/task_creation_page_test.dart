import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/pages/TaskCreationPage/task_creation_page.dart';
import 'package:janus/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> useTallViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets('createTaskPage 返回 WoltModalSheet 页面列表', (tester) async {
    await useTallViewport(tester);

    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            ctx = context;
            return const Scaffold(body: SizedBox());
          },
        ),
      ),
    );

    final pages = TaskCreationPage.createTaskPage(ctx);

    expect(pages, isNotEmpty);
    expect(pages.first, isA<SliverWoltModalSheetPage>());
  });

  testWidgets('新建任务弹窗渲染标题与表单', (tester) async {
    await useTallViewport(tester);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => WoltModalSheet.show<void>(
                    context: context,
                    pageListBuilder: (modalContext) =>
                        TaskCreationPage.createTaskPage(modalContext),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    // WoltModalSheet 使用路由转场动画，分帧推进（避免 pumpAndSettle：ClassicPage 的
    // ReelText 有持续动画会导致其永不 settle）。
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('新建任务'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
