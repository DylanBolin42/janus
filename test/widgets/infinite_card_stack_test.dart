import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/shared/widgets/infinite_card_stack/infinite_card_stack.dart';
import 'package:janus/shared/widgets/infinite_card_stack/infinite_card_stack_controller.dart';
import 'package:janus/shared/widgets/infinite_card_stack/models/card_transform.dart';
import 'package:janus/shared/widgets/infinite_card_stack/utils/math.dart';

void main() {
  group('InfiniteCardStack Math & Transform Unit Tests', () {
    test('CardTransform identity and lerpTo test', () {
      const start = CardTransform.identity();
      final end = CardTransform(
        offset: const Offset(10.0, 20.0),
        scale: 0.9,
        opacity: 0.5,
        rotation: 0.1,
        zIndex: 2.0,
        elevation: 4.0,
      );

      final half = start.lerpTo(end, 0.5);

      expect(half.offset, const Offset(5.0, 10.0));
      expect(half.scale, closeTo(0.95, 0.001));
      expect(half.opacity, closeTo(0.75, 0.001));
      expect(half.rotation, closeTo(0.05, 0.001));
      expect(half.zIndex, closeTo(1.5, 0.001));
      expect(half.elevation, closeTo(2.0, 0.001));
    });

    test('Quadratic Bezier path math evaluation', () {
      const p0 = Offset(0.0, 0.0);
      const p1 = Offset(100.0, 50.0);
      const p2 = Offset(0.0, 100.0);

      final pointAtStart = InfiniteCardStackMath.evaluateQuadraticBezier(p0, p1, p2, 0.0);
      final pointAtHalf = InfiniteCardStackMath.evaluateQuadraticBezier(p0, p1, p2, 0.5);
      final pointAtEnd = InfiniteCardStackMath.evaluateQuadraticBezier(p0, p1, p2, 1.0);

      expect(pointAtStart, const Offset(0.0, 0.0));
      // B(0.5) = 0.25 * p0 + 0.5 * p1 + 0.25 * p2 = (0,0) + (50, 25) + (0, 25) = (50, 50)
      expect(pointAtHalf, const Offset(50.0, 50.0));
      expect(pointAtEnd, const Offset(0.0, 100.0));
    });
  });

  group('InfiniteCardStack Widget & Controller Integration Tests', () {
    testWidgets('Renders items lazily and maps active slots', (WidgetTester tester) async {
      final controller = InfiniteCardStackController();
      final items = List.generate(10, (index) => 'Item $index');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 400,
              child: InfiniteCardStack.builder(
                itemCount: items.length,
                controller: controller,
                itemBuilder: (context, index) {
                  return Container(
                    key: ValueKey(items[index]),
                    child: Text(items[index]),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Verify that Item 0, Item 1, Item 2, Item 3 are rendered
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);

      // Verify that Item 5 is not rendered yet (as visibleCount is 4)
      expect(find.text('Item 5'), findsNothing);

      // Trigger next transition programmatically
      controller.next();
      await tester.pump(); // Start transition
      await tester.pump(const Duration(milliseconds: 600)); // Complete transition

      // Now index is 1, so Item 1 is the top card, and Item 4 is at the bottom
      expect(controller.currentIndex, 1);
      expect(find.text('Item 4'), findsOneWidget);

      // Jump to a far index
      controller.jumpTo(5);
      await tester.pump();

      expect(controller.currentIndex, 5);
      expect(find.text('Item 5'), findsOneWidget);
      expect(find.text('Item 6'), findsOneWidget);
    });
  });
}
