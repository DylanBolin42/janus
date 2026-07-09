import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/main.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      LiquidGlassWidgets.wrap(child: const ProviderScope(child: MyApp())),
    );

    // 初始路由是 /inbox，应显示 InboxPage 中的提示文字
    expect(find.text('Welcome to Janus'), findsOneWidget);
  });
}
