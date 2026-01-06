import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/domain/models/category.dart';
import 'package:street_cart_pos/domain/models/product.dart';
import 'package:street_cart_pos/ui/menu/widgets/menu_tab/menu_page.dart';
import '../../helpers/fake_menu_repository.dart';

void main() {
  setUp(() async {
    MenuRepository.setInstance(FakeMenuRepository());
    final repo = MenuRepository();
    await repo.reset();

    // Seed Categories
    await repo.addCategory(Category(name: 'Coffee'));
    await repo.addCategory(Category(name: 'Matcha'));

    final coffee = repo.categories.firstWhere((c) => c.name == 'Coffee');
    final matcha = repo.categories.firstWhere((c) => c.name == 'Matcha');

    // Seed Products
    await repo.addProduct(
      Product(name: 'Iced Latte', basePrice: 2.5, category: coffee),
    );
    await repo.addProduct(
      Product(name: 'Cappuccino', basePrice: 3.0, category: coffee),
    );
    await repo.addProduct(
      Product(name: 'Green Tea Latte', basePrice: 3.5, category: matcha),
    );
  });

  testWidgets('MenuPage filters products by category and search query', (
    WidgetTester tester,
  ) async {
    // Wrap in MaterialApp because MenuPage uses Navigator and Theme
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MenuPage())),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // 1. Verify Initial State (All items visible)
    // Mock data: Iced Latte (Coffee), Cappuccino (Coffee), Green Tea Latte (Matcha)
    expect(find.text('Iced Latte'), findsAtLeastNWidgets(1));
    expect(find.text('Cappuccino'), findsAtLeastNWidgets(1));
    expect(find.text('Green Tea Latte'), findsAtLeastNWidgets(1));

    // 2. Filter by Category: Coffee
    // Find the 'Coffee' chip
    final coffeeChip = find.widgetWithText(ChoiceChip, 'Coffee');
    expect(coffeeChip, findsOneWidget);

    // Tap it
    await tester.tap(coffeeChip);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    // Verify: Only Coffee items visible
    expect(find.text('Iced Latte'), findsAtLeastNWidgets(1));
    expect(find.text('Cappuccino'), findsAtLeastNWidgets(1));
    expect(find.text('Green Tea Latte'), findsNothing);

    // 3. Filter by Search: "Latte" (while Category is Coffee)
    // Find search bar
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);

    // Enter text
    await tester.enterText(searchField, 'Latte');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    // Verify: Only "Iced Latte" visible (Coffee AND Latte)
    // "Cappuccino" (Coffee but no Latte) -> Hidden
    // "Green Tea Latte" (Latte but not Coffee) -> Hidden
    expect(find.text('Iced Latte'), findsAtLeastNWidgets(1));
    expect(find.text('Cappuccino'), findsNothing);
    expect(find.text('Green Tea Latte'), findsNothing);

    // 4. Reset Category to All (Search "Latte" still active)
    final allChip = find.widgetWithText(ChoiceChip, 'All');
    await tester.tap(allChip);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    // Verify: "Iced Latte" and "Green Tea Latte" visible
    expect(find.text('Iced Latte'), findsAtLeastNWidgets(1));
    expect(find.text('Green Tea Latte'), findsAtLeastNWidgets(1));
    expect(find.text('Cappuccino'), findsNothing);
  });
}
