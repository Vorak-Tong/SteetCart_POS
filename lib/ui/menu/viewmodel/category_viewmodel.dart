import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import 'package:uuid/uuid.dart';

class CategoryViewModel extends ChangeNotifier {
  final MenuRepository _repository = MenuRepository();

  CategoryViewModel() {
    _repository.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _repository.removeListener(notifyListeners);
    super.dispose();
  }

  List<Category> get categories => List.unmodifiable(_repository.categories);

  int getProductCountForCategory(String categoryId) {
    return _repository.products
        .where((p) => p.category?.id == categoryId)
        .length;
  }

  Future<void> addCategory(String name, bool isActive) async {
    try {
      await _repository.addCategory(Category(
        id: const Uuid().v4(),
        name: name,
        isActive: isActive,
      ));
    } catch (e) {
      print('Error adding category: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(Category category, String newName, bool newIsActive) async {
    await _repository.updateCategory(Category(
      id: category.id,
      name: newName,
      isActive: newIsActive,
    ));
  }

  Future<void> deleteCategory(Category category) async {
    await _repository.deleteCategory(category.id);
  }
}