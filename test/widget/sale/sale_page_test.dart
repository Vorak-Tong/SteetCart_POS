import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:street_cart_pos/ui/core/theme/app_theme.dart';
import 'package:street_cart_pos/ui/sale/widgets/sale_tab/sale_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SalePage', () {
    Future<void> pumpSalePage(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: SalePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('filters products by category chip', (tester) async {
      await pumpSalePage(tester);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Beverages'));
      await tester.pumpAndSettle();

      expect(find.text('Soda Can'), findsOneWidget);

      final gridScrollable = find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first;
      await tester.scrollUntilVisible(
        find.text('Iced Tea'),
        300,
        scrollable: gridScrollable,
      );
      expect(find.text('Iced Tea'), findsOneWidget);

      expect(find.text('Chicken Over Rice'), findsNothing);
      expect(find.text('Fries'), findsNothing);
    });

    testWidgets('filters products by search query', (tester) async {
      await pumpSalePage(tester);

      await tester.enterText(find.byType(TextField), 'rice');
      await tester.pumpAndSettle();

      expect(find.text('Chicken Over Rice'), findsOneWidget);
      expect(find.text('Lamb Over Rice'), findsOneWidget);

      expect(find.text('Falafel Wrap'), findsNothing);
      expect(find.text('Soda Can'), findsNothing);
    });

    testWidgets('combines category chip + search query', (tester) async {
      await pumpSalePage(tester);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Sides'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'sauce');
      await tester.pumpAndSettle();

      expect(find.text('Extra White Sauce'), findsOneWidget);
      expect(find.text('Fries'), findsNothing);
      expect(find.text('Chicken Over Rice'), findsNothing);
    });

    testWidgets('opens selection sheet when tapping a product', (tester) async {
      await pumpSalePage(tester);

      await tester.tap(find.text('Chicken Over Rice'));
      await tester.pumpAndSettle();

      expect(find.text('Add to cart'), findsOneWidget);
    });
  });
}

