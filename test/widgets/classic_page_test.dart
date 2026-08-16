import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/pages/TaskCreationPage/subPage/classic_page.dart';
import 'package:janus/theme/theme.dart';

Widget createClassicPage() {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(body: ClassicPage()),
    ),
  );
}

void main() {
  testWidgets('ClassicPage renders without crashing', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createClassicPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
  });
}
