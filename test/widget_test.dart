import 'package:flutter_test/flutter_test.dart';
import 'package:janus/main.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // 由于 main() 中有异步初始化，我们在测试中手动包装应用
    // 注意：LiquidGlassWidgets 可能在测试环境中需要特殊处理，
    // 这里我们简单测试 MyApp 是否能渲染。
    
    await tester.pumpWidget(
      LiquidGlassWidgets.wrap(child: const MyApp())
    );

    // 验证首页是否显示了预期的文本
    // 初始路由是 /inbox，应该显示 AtriumPage 中的 'Welcome to Janus'
    expect(find.text('Welcome to Janus'), findsOneWidget);
  });
}
