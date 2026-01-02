import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';

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

  void addCategory(String name, bool isActive) {
    _repository.addCategory(Category(name: name, isActive: isActive));
  }

  void updateCategory(Category category, String newName, bool newIsActive) {
    _repository.updateCategory(Category(
      id: category.id,
      name: newName,
      isActive: newIsActive,
    ));
  }

  void deleteCategory(Category category) {
    _repository.deleteCategory(category.id);
  }
}