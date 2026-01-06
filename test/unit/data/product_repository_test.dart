import 'package:flutter_test/flutter_test.dart';
import 'package:street_cart_pos/data/repositories/category_repository.dart';
import 'package:street_cart_pos/data/repositories/modifier_repository.dart';
import 'package:street_cart_pos/data/repositories/product_repository.dart';
import 'package:street_cart_pos/domain/models/category.dart';
import 'package:street_cart_pos/domain/models/modifier_group.dart';
import 'package:street_cart_pos/domain/models/modifier_option.dart';
import 'package:street_cart_pos/domain/models/product.dart';
import '../../helpers/database_test_helper.dart';
import 'package:uuid/uuid.dart';

void main() {
  setupDatabaseTests();

  test(
    'ProductRepository: Full Lifecycle (Create, Read, Update w/ Modifiers)',
    () async {
      final repo = ProductRepository();
      final categoryRepo = CategoryRepository();
      final modifierRepo = ModifierRepository();

      // 1. Create Category
      final category = Category(id: const Uuid().v4(), name: 'Food');
      await categoryRepo.saveCategory(category);

      // 2. Create Product with Modifiers
      final modifierOption = ModifierOptions(
        id: const Uuid().v4(),
        name: 'Extra Cheese',
        price: 0.5,
      );
      final modifierGroup = ModifierGroup(
        id: const Uuid().v4(),
        name: 'Toppings',
        modifierOptions: [modifierOption],
      );

      // Global modifier groups must exist in the DB before attaching them to products.
      await modifierRepo.saveModifierGroup(modifierGroup);

      final product = Product(
        id: const Uuid().v4(),
        name: 'Burger',
        basePrice: 5.0,
        category: category,
        modifierGroups: [modifierGroup],
      );

      await repo.createProduct(product);

      // 3. Verify Save
      final products = await repo.getProducts();
      expect(products.length, 1);
      final savedProduct = products.first;
      expect(savedProduct.name, 'Burger');
      expect(savedProduct.category?.name, 'Food');
      expect(savedProduct.modifierGroups.length, 1);
      expect(
        savedProduct.modifierGroups.first.modifierOptions.first.name,
        'Extra Cheese',
      );

      // 4. Update Product (Change name and remove modifiers)
      final updatedProduct = Product(
        id: product.id,
        name: 'Cheeseburger', // Changed name
        basePrice: 6.0,
        category: category,
        modifierGroups: [], // Removed modifiers
      );
      await repo.updateProduct(updatedProduct);

      // 5. Verify Update
      final productsAfterUpdate = await repo.getProducts();
      expect(productsAfterUpdate.first.name, 'Cheeseburger');
      expect(productsAfterUpdate.first.modifierGroups, isEmpty);

      // 6. Delete Product
      await repo.deleteProduct(product.id);
      expect(await repo.getProducts(), isEmpty);
    },
  );
}
