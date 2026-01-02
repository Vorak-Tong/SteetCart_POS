import 'package:flutter/foundation.dart' show ChangeNotifier, visibleForTesting;
import 'package:street_cart_pos/domain/models/product_model.dart';

class MenuRepository extends ChangeNotifier {
  static final MenuRepository _instance = MenuRepository._internal();

  factory MenuRepository() => _instance;

  MenuRepository._internal() {
    _initializeMockData();
  }

  final List<Category> _categories = [];
  final List<ModifierGroup> _modifierGroups = [];
  final List<Product> _products = [];

  List<Category> get categories => _categories;
  List<ModifierGroup> get modifierGroups => _modifierGroups;
  List<Product> get products => _products;

  // Category Actions
  void addCategory(Category category) {
    _categories.add(category);
    notifyListeners();
  }

  void updateCategory(Category category) {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      notifyListeners();
    }
  }

  void deleteCategory(String id) {
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // Modifier Actions
  void addModifierGroup(ModifierGroup group) {
    _modifierGroups.add(group);
    notifyListeners();
  }

  void updateModifierGroup(ModifierGroup group) {
    final index = _modifierGroups.indexWhere((g) => g.id == group.id);
    if (index != -1) {
      _modifierGroups[index] = group;
      notifyListeners();
    }
  }

  void deleteModifierGroup(String id) {
    _modifierGroups.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  // Product Actions
  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  @visibleForTesting
  void reset() {
    _categories.clear();
    _modifierGroups.clear();
    _products.clear();
    _initializeMockData();
    notifyListeners();
  }

  void _initializeMockData() {
    // Categories
    _categories.addAll([
      Category(name: 'Coffee'),
      Category(name: 'Tea'),
      Category(name: 'Matcha'),
      Category(name: 'Smoothies'),
    ]);

    // Modifiers
    _modifierGroups.addAll([
      ModifierGroup(
        name: 'Ice Level',
        modifierOptions: [
          ModifierOptions(name: 'No Ice'),
          ModifierOptions(name: 'Less Ice'),
          ModifierOptions(name: 'Normal Ice'),
          ModifierOptions(name: 'Extra Ice'),
        ],
      ),
      ModifierGroup(
        name: 'Sugar Level',
        modifierOptions: [
          ModifierOptions(name: '0%'),
          ModifierOptions(name: '25%'),
          ModifierOptions(name: '50%'),
          ModifierOptions(name: '100%'),
        ],
      ),
      ModifierGroup(
        name: 'Size',
        modifierOptions: [
          ModifierOptions(name: 'Small'),
          ModifierOptions(name: 'Medium'),
          ModifierOptions(name: 'Large'),
        ],
      ),
      ModifierGroup(name: 'Toppings'),
    ]);

    // Products
    _products.addAll([
      Product(
        name: 'Iced Latte',
        basePrice: 2.50,
        category: _categories.firstWhere((c) => c.name == 'Coffee'),
        modifierGroups: [
          _modifierGroups.firstWhere((m) => m.name == 'Sugar Level'),
          _modifierGroups.firstWhere((m) => m.name == 'Size'),
        ],
      ),
      Product(
        name: 'Cappuccino',
        basePrice: 3.00,
        category: _categories.firstWhere((c) => c.name == 'Coffee'),
      ),
      Product(
        name: 'Green Tea Latte',
        basePrice: 3.50,
        category: _categories.firstWhere((c) => c.name == 'Matcha'),
        modifierGroups: [
          _modifierGroups.firstWhere((m) => m.name == 'Toppings')
        ],
      ),
    ]);
  }
}