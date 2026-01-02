import 'package:flutter_test/flutter_test.dart';
import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/menu_viewmodel.dart';

void main() {
  late MenuViewModel viewModel;

  setUp(() {
    MenuRepository().reset();
    viewModel = MenuViewModel();
  });

  test('Initial state loads products and categories', () {
    expect(viewModel.products.length, 3); // Mock data
    expect(viewModel.categories.length, 4);
    expect(viewModel.filteredProducts.length, 3);
  });

  test('setSearchQuery filters products by name', () {
    // "Latte" matches "Iced Latte" and "Green Tea Latte"
    viewModel.setSearchQuery('Latte');
    
    expect(viewModel.searchQuery, 'Latte');
    expect(viewModel.filteredProducts.length, 2);
    expect(viewModel.filteredProducts.any((p) => p.name == 'Cappuccino'), isFalse);
  });

  test('setSelectedCategoryId filters products by category', () {
    final coffeeCategory = viewModel.categories.firstWhere((c) => c.name == 'Coffee');
    
    viewModel.setSelectedCategoryId(coffeeCategory.id);
    
    expect(viewModel.selectedCategoryId, coffeeCategory.id);
    // Should match "Iced Latte" and "Cappuccino"
    expect(viewModel.filteredProducts.length, 2);
    expect(viewModel.filteredProducts.every((p) => p.category?.id == coffeeCategory.id), isTrue);
  });

  test('Combined filter: Category AND Search', () {
    final coffeeCategory = viewModel.categories.firstWhere((c) => c.name == 'Coffee');
    
    // Filter by Coffee
    viewModel.setSelectedCategoryId(coffeeCategory.id);
    // Filter by "Iced"
    viewModel.setSearchQuery('Iced');

    // Should only match "Iced Latte"
    // "Cappuccino" is Coffee but no "Iced"
    // "Green Tea Latte" has "Iced" but is not Coffee
    expect(viewModel.filteredProducts.length, 1);
    expect(viewModel.filteredProducts.first.name, 'Iced Latte');
  });

  test('addProduct adds product to list', () {
    final product = Product(
      name: 'New Item',
      basePrice: 5.0,
    );

    viewModel.addProduct(product);

    expect(viewModel.products.length, 4);
    expect(viewModel.products.last.name, 'New Item');
    
    // Should also appear in filtered list (since no filters active)
    expect(viewModel.filteredProducts.length, 4);
  });
}
