import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:janus/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('MyApp renders without crashing', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    // Allow async providers to settle (settings load from SharedPreferences)
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // The router should have initialised and shows the InboxPage
    expect(find.text('Welcome to Janus'), findsOneWidget);
  });
}
