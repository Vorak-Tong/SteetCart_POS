import 'package:flutter_test/flutter_test.dart';
import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/category_viewmodel.dart';
import '../../../helpers/fake_menu_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  late CategoryViewModel viewModel;

  setUp(() async {
    MenuRepository.setInstance(FakeMenuRepository());

    final repo = MenuRepository();
    await repo.addCategory(Category(id: const Uuid().v4(), name: 'Coffee'));
    await repo.addCategory(Category(id: const Uuid().v4(), name: 'Tea'));
    await repo.addCategory(Category(id: const Uuid().v4(), name: 'Snacks'));
    await repo.addCategory(Category(id: const Uuid().v4(), name: 'Desserts'));

    final coffee = repo.categories.firstWhere((c) => c.name == 'Coffee');
    await repo.addProduct(Product(id: const Uuid().v4(), name: 'Iced Latte', basePrice: 2.5, category: coffee));
    await repo.addProduct(Product(id: const Uuid().v4(), name: 'Cappuccino', basePrice: 3.0, category: coffee));

    viewModel = CategoryViewModel();
  });

  test('Initial state loads categories from repository', () {
    // Mock data has 4 categories
    expect(viewModel.categories.length, 4);
    expect(viewModel.categories.any((c) => c.name == 'Coffee'), isTrue);
  });

  test('addCategory adds a new category', () async {
    await viewModel.addCategory('Juice');
    
    expect(viewModel.categories.length, 5);
    expect(viewModel.categories.last.name, 'Juice');
  });

  test('updateCategory modifies existing category', () async {
    final categoryToUpdate = viewModel.categories.first; // Coffee
    
    await viewModel.updateCategory(categoryToUpdate, 'Premium Coffee');
    
    final updated = viewModel.categories.firstWhere((c) => c.id == categoryToUpdate.id);
    expect(updated.name, 'Premium Coffee');
  });

  test('deleteCategory removes category', () async {
    final categoryToDelete = viewModel.categories.first;
    
    await viewModel.deleteCategory(categoryToDelete);
    
    expect(viewModel.categories.length, 3);
    expect(viewModel.categories.any((c) => c.id == categoryToDelete.id), isFalse);
  });

  test('getProductCountForCategory returns correct count', () async {
    // Mock data: Coffee has 2 products (Iced Latte, Cappuccino)
    final coffee = viewModel.categories.firstWhere((c) => c.name == 'Coffee');
    expect(viewModel.getProductCountForCategory(coffee.id), 2);

    // Add a new product to Coffee via Repository directly to test the count logic
    await MenuRepository().addProduct(Product(
      id: const Uuid().v4(),
      name: 'Espresso',
      basePrice: 2.0,
      category: coffee,
    ));

    // ViewModel should reflect the change immediately because it listens to Repository
    expect(viewModel.getProductCountForCategory(coffee.id), 3);
  });
}
