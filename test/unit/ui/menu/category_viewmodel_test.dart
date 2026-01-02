import 'package:flutter_test/flutter_test.dart';
import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/category_viewmodel.dart';

void main() {
  late CategoryViewModel viewModel;

  setUp(() {
    MenuRepository().reset();
    viewModel = CategoryViewModel();
  });

  test('Initial state loads categories from repository', () {
    // Mock data has 4 categories
    expect(viewModel.categories.length, 4);
    expect(viewModel.categories.any((c) => c.name == 'Coffee'), isTrue);
  });

  test('addCategory adds a new category', () {
    viewModel.addCategory('Juice', true);
    
    expect(viewModel.categories.length, 5);
    expect(viewModel.categories.last.name, 'Juice');
    expect(viewModel.categories.last.isActive, isTrue);
  });

  test('updateCategory modifies existing category', () {
    final categoryToUpdate = viewModel.categories.first; // Coffee
    
    viewModel.updateCategory(categoryToUpdate, 'Premium Coffee', false);
    
    final updated = viewModel.categories.firstWhere((c) => c.id == categoryToUpdate.id);
    expect(updated.name, 'Premium Coffee');
    expect(updated.isActive, isFalse);
  });

  test('deleteCategory removes category', () {
    final categoryToDelete = viewModel.categories.first;
    
    viewModel.deleteCategory(categoryToDelete);
    
    expect(viewModel.categories.length, 3);
    expect(viewModel.categories.any((c) => c.id == categoryToDelete.id), isFalse);
  });

  test('getProductCountForCategory returns correct count', () {
    // Mock data: Coffee has 2 products (Iced Latte, Cappuccino)
    final coffee = viewModel.categories.firstWhere((c) => c.name == 'Coffee');
    expect(viewModel.getProductCountForCategory(coffee.id), 2);

    // Add a new product to Coffee via Repository directly to test the count logic
    MenuRepository().addProduct(Product(
      name: 'Espresso',
      basePrice: 2.0,
      category: coffee,
    ));

    // ViewModel should reflect the change immediately because it listens to Repository
    expect(viewModel.getProductCountForCategory(coffee.id), 3);
  });
}
