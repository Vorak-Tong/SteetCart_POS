import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';

class SaleViewModel extends ChangeNotifier {
  static const String allCategoryId = '__all__';
  static const String uncategorizedCategoryId = '__uncategorized__';

  final MenuRepository _repository;

  String _selectedCategoryId = allCategoryId;
  String _searchQuery = '';

  SaleViewModel({MenuRepository? repository})
    : _repository = repository ?? MenuRepository() {
    _repository.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _repository.removeListener(notifyListeners);
    super.dispose();
  }

  List<Product> get products =>
      List.unmodifiable(_repository.products.where((p) => p.isActive));

  List<Category> get categories {
    final byId = <String, Category>{};
    for (final product in products) {
      final category = product.category;
      if (category == null) continue;
      byId.putIfAbsent(category.id, () => category);
    }

    final list = byId.values.toList(growable: false);
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  bool get hasUncategorizedProducts => products.any((p) => p.category == null);

  String get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;

  void setSelectedCategoryId(String id) {
    if (_selectedCategoryId == id) {
      return;
    }

    _selectedCategoryId = id;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) {
      return;
    }

    _searchQuery = query;
    notifyListeners();
  }

  List<Product> get filteredProducts {
    final query = _searchQuery.trim().toLowerCase();

    Iterable<Product> result = products;
    if (_selectedCategoryId == uncategorizedCategoryId) {
      result = result.where((product) => product.category == null);
    } else if (_selectedCategoryId != allCategoryId) {
      result = result.where(
        (product) => product.category?.id == _selectedCategoryId,
      );
    }

    if (query.isNotEmpty) {
      result = result.where(
        (product) => product.name.toLowerCase().contains(query),
      );
    }

    return result.toList(growable: false);
  }
}
