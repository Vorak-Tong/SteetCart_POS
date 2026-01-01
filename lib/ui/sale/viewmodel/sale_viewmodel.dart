import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:street_cart_pos/domain/models/product_model.dart';

class SaleViewModel extends ChangeNotifier {
  SaleViewModel() {
    _products = _mockProducts();
    _categories = _uniqueCategories(_products);
  }

  static const String allCategoryId = '__all__';

  late final List<Product> _products;
  late final List<Category> _categories;

  String _selectedCategoryId = allCategoryId;
  String _searchQuery = '';

  List<Product> get products => _products;
  List<Category> get categories => _categories;

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

    Iterable<Product> result = _products;
    if (_selectedCategoryId != allCategoryId) {
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

List<Category> _uniqueCategories(List<Product> products) {
  final byId = <String, Category>{};
  for (final product in products) {
    final category = product.category;
    if (category == null) {
      continue;
    }

    byId.putIfAbsent(category.id, () => category);
  }
  return byId.values.toList(growable: false);
}

List<Product> _mockProducts() {
  final beverages = Category(id: 'cat-bev', name: 'Beverages');
  final entrees = Category(id: 'cat-ent', name: 'Entrees');
  final sides = Category(id: 'cat-side', name: 'Sides');

  return [
    Product(
      id: 'prd-001',
      name: 'Chicken Over Rice',
      basePrice: 10.00,
      category: entrees,
    ),
    Product(
      id: 'prd-002',
      name: 'Lamb Over Rice',
      basePrice: 11.00,
      category: null,
    ),
    Product(
      id: 'prd-003',
      name: 'Falafel Wrap',
      basePrice: 9.00,
      category: entrees,
    ),
    Product(
      id: 'prd-004',
      name: 'Fries',
      basePrice: 3.50,
      category: sides,
    ),
    Product(
      id: 'prd-005',
      name: 'Soda Can',
      basePrice: 1.50,
      category: beverages,
    ),
    Product(
      id: 'prd-006',
      name: 'Water Bottle',
      basePrice: 1.25,
      category: beverages,
    ),
    Product(
      id: 'prd-007',
      name: 'Iced Tea',
      basePrice: 2.25,
      category: beverages,
    ),
    Product(
      id: 'prd-008',
      name: 'Extra White Sauce',
      basePrice: 0.75,
      category: sides,
    ),
  ];
}
