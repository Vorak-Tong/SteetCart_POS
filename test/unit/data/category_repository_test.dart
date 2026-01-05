import 'package:flutter_test/flutter_test.dart';
import 'package:street_cart_pos/data/repositories/category_repository.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import '../../helpers/database_test_helper.dart';
import 'package:uuid/uuid.dart';

void main() {
  setupDatabaseTests();

  test('CategoryRepository: CRUD Operations', () async {
    final repo = CategoryRepository();

    // 1. Create
    final category = Category(id: const Uuid().v4(), name: 'Snacks');
    await repo.saveCategory(category);

    // 2. Read
    final categories = await repo.getCategories();
    expect(categories.length, 1);
    expect(categories.first.name, 'Snacks');

    // 3. Update (assuming saveCategory handles upsert or we have updateCategory)
    // If your repo uses saveCategory for both, we test that.
    final updatedCategory = Category(id: category.id, name: 'Super Snacks');
    await repo.saveCategory(updatedCategory);
    
    final fetchedUpdated = (await repo.getCategories()).first;
    expect(fetchedUpdated.name, 'Super Snacks');

    // 4. Delete
    await repo.deleteCategory(category.id);
    expect(await repo.getCategories(), isEmpty);
  });
}
