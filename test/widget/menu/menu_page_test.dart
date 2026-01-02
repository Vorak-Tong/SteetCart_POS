import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:street_cart_pos/ui/menu/widgets/menu_page.dart';

void main() {
  testWidgets('MenuPage filters products by category and search query', (WidgetTester tester) async {
    // Wrap in MaterialApp because MenuPage uses Navigator and Theme
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: MenuPage(),
      ),
    ));

    // Wait for animations/rendering
    await tester.pumpAndSettle();

    // 1. Verify Initial State (All items visible)
    // Mock data: Iced Latte (Coffee), Cappuccino (Coffee), Green Tea Latte (Matcha)
    expect(find.text('Iced Latte'), findsOneWidget);
    expect(find.text('Cappuccino'), findsOneWidget);
    expect(find.text('Green Tea Latte'), findsOneWidget);

    // 2. Filter by Category: Coffee
    // Find the 'Coffee' chip
    final coffeeChip = find.widgetWithText(ChoiceChip, 'Coffee');
    expect(coffeeChip, findsOneWidget);

    // Tap it
    await tester.tap(coffeeChip);
    await tester.pumpAndSettle();

    // Verify: Only Coffee items visible
    expect(find.text('Iced Latte'), findsOneWidget);
    expect(find.text('Cappuccino'), findsOneWidget);
    expect(find.text('Green Tea Latte'), findsNothing);

    // 3. Filter by Search: "Latte" (while Category is Coffee)
    // Find search bar
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);

    // Enter text
    await tester.enterText(searchField, 'Latte');
    await tester.pumpAndSettle();

    // Verify: Only "Iced Latte" visible (Coffee AND Latte)
    // "Cappuccino" (Coffee but no Latte) -> Hidden
    // "Green Tea Latte" (Latte but not Coffee) -> Hidden
    expect(find.text('Iced Latte'), findsOneWidget);
    expect(find.text('Cappuccino'), findsNothing);
    expect(find.text('Green Tea Latte'), findsNothing);

    // 4. Reset Category to All (Search "Latte" still active)
    final allChip = find.widgetWithText(ChoiceChip, 'All');
    await tester.tap(allChip);
    await tester.pumpAndSettle();

    // Verify: "Iced Latte" and "Green Tea Latte" visible
    expect(find.text('Iced Latte'), findsOneWidget);
    expect(find.text('Green Tea Latte'), findsOneWidget);
    expect(find.text('Cappuccino'), findsNothing);
  });
}