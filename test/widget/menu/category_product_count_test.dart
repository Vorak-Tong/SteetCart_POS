import 'package:flutter/material.dart' hide Category;
import 'package:flutter_test/flutter_test.dart';
import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import 'package:street_cart_pos/ui/menu/widgets/category_tab/category_page.dart';
import '../../helpers/fake_menu_repository.dart';

void main() {
  setUp(() async {
    MenuRepository.setInstance(FakeMenuRepository());

    // Seed Data
    final repo = MenuRepository();
    await repo.addCategory(Category(name: 'Coffee'));
    final coffee = repo.categories.first;
    await repo.addProduct(Product(name: 'Iced Latte', basePrice: 3.5, category: coffee));
    await repo.addProduct(Product(name: 'Cappuccino', basePrice: 4.0, category: coffee));
  });

  testWidgets('CategoryPage updates item count when product is added', (WidgetTester tester) async {
    // 1. Pump CategoryPage
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: CategoryPage(),
      ),
    ));

    // Wait for initial render
    await tester.pumpAndSettle();

    // 2. Verify Initial State for 'Coffee'
    // The mock data initializes with 2 Coffee items (Iced Latte, Cappuccino)
    // CategoryItemCard uses a Dismissible with a ValueKey(name)
    final coffeeCardFinder = find.byKey(const ValueKey('Coffee'));
    expect(coffeeCardFinder, findsOneWidget);

    expect(
      find.descendant(of: coffeeCardFinder, matching: find.text('2 items')),
      findsOneWidget,
      reason: 'Initial count for Coffee should be 2',
    );

    // 3. Add a new Product to 'Coffee' via Repository
    // Since MenuRepository is a singleton, we can access the same instance used by the UI
    final repo = MenuRepository();
    final coffeeCategory = repo.categories.firstWhere((c) => c.name == 'Coffee');
    
    await repo.addProduct(Product(
      name: 'Espresso',
      basePrice: 2.0,
      category: coffeeCategory,
    ));

    // 4. Pump to process the ChangeNotifier notification and rebuild UI
    await tester.pump();

    // Verify repo has updated data (sanity check)
    expect(repo.products.where((p) => p.category?.id == coffeeCategory.id).length, 3);

    // 5. Verify Updated Count
    expect(
      find.descendant(of: coffeeCardFinder, matching: find.text('3 items')),
      findsOneWidget,
      reason: 'Count for Coffee should update to 3 after adding a product',
    );
  });
}