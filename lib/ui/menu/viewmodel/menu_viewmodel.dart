import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';

class MenuViewModel extends ChangeNotifier {
  final MenuRepository _repository = MenuRepository();

  MenuViewModel() {
    _repository.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _repository.removeListener(notifyListeners);
    super.dispose();
  }

  static const String allCategoryId = '__all__';

  String _selectedCategoryId = allCategoryId;
  String _searchQuery = '';

  // Getters
  List<Product> get products => List.unmodifiable(_repository.products);
  List<Category> get categories => List.unmodifiable(_repository.categories);
  List<ModifierGroup> get modifierGroups => List.unmodifiable(_repository.modifierGroups);

  String get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;

  List<Product> get filteredProducts {
    final query = _searchQuery.trim().toLowerCase();
    return _repository.products.where((p) {
      final matchesCategory = _selectedCategoryId == allCategoryId ||
          p.category?.id == _selectedCategoryId;

      final matchesSearch = query.isEmpty ||
          p.name.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  // Actions
  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategoryId(String id) {
    if (_selectedCategoryId == id) return;
    _selectedCategoryId = id;
    notifyListeners();
  }

  void addProduct(Product product) {
    _repository.addProduct(product);
  }
}