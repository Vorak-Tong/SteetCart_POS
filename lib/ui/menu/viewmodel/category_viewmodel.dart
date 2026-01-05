import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import 'package:uuid/uuid.dart';

class CategoryViewModel extends ChangeNotifier {
  final MenuRepository _repository = MenuRepository();
  final Set<String> _pendingDeleteIds = {};
  bool _disposed = false;

  CategoryViewModel() {
    _repository.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _disposed = true;
    _repository.removeListener(notifyListeners);
    super.dispose();
  }

  List<Category> get categories => List.unmodifiable(
    _repository.categories.where((c) => !_pendingDeleteIds.contains(c.id)),
  );

  int getProductCountForCategory(String categoryId) {
    return _repository.products
        .where((p) => p.isActive && p.category?.id == categoryId)
        .length;
  }

  Future<void> addCategory(String name) async {
    try {
      await _repository.addCategory(
        Category(id: const Uuid().v4(), name: name),
      );
    } catch (e) {
      print('Error adding category: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(Category category, String newName) async {
    await _repository.updateCategory(Category(id: category.id, name: newName));
  }

  Future<void> deleteCategory(Category category) async {
    if (_pendingDeleteIds.contains(category.id)) return;
    _pendingDeleteIds.add(category.id);
    if (!_disposed) notifyListeners();

    try {
      await _repository.deleteCategory(category.id);
    } catch (_) {
      _pendingDeleteIds.remove(category.id);
      if (!_disposed) notifyListeners();
      rethrow;
    } finally {
      _pendingDeleteIds.remove(category.id);
    }
  }
}
