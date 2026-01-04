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
      modifierGroups: [
        ModifierGroup(
          id: 'mod-sugar-level',
          name: 'Sugar Level',
          selectionType: ModifierSelectionType.single,
          priceBehavior: ModifierPriceBehavior.none,
          minSelection: 1,
          maxSelection: 1,
          modifierOptions: [
            ModifierOptions(id: 'sugar-0', name: 'No Sugar'),
            ModifierOptions(id: 'sugar-1', name: 'Less Sugar'),
            ModifierOptions(id: 'sugar-2', name: 'Regular', isDefault: true),
            ModifierOptions(id: 'sugar-3', name: 'Extra Sugar'),
          ],
        ),
        ModifierGroup(
          id: 'mod-size',
          name: 'Size',
          selectionType: ModifierSelectionType.single,
          priceBehavior: ModifierPriceBehavior.fixed,
          minSelection: 1,
          maxSelection: 1,
          modifierOptions: [
            ModifierOptions(id: 'size-m', name: 'Medium', price: 0, isDefault: true),
            ModifierOptions(id: 'size-l', name: 'Large', price: 0.75),
            ModifierOptions(id: 'size-xl', name: 'X-Large', price: 1.25),
          ],
        ),
        ModifierGroup(
          id: 'mod-toppings',
          name: 'Toppings',
          selectionType: ModifierSelectionType.multi,
          priceBehavior: ModifierPriceBehavior.fixed,
          minSelection: 0,
          maxSelection: 0,
          modifierOptions: [
            ModifierOptions(id: 'top-lemon', name: 'Lemon', price: 0.25),
            ModifierOptions(id: 'top-mint', name: 'Mint', price: 0.25),
            ModifierOptions(id: 'top-boba', name: 'Boba', price: 0.75),
          ],
        ),
      ],
    ),
    Product(
      id: 'prd-008',
      name: 'Extra White Sauce',
      basePrice: 0.75,
      category: sides,
    ),
  ];
}
