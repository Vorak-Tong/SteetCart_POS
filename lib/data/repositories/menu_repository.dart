import 'package:flutter/foundation.dart' show ChangeNotifier, visibleForTesting;
import 'package:street_cart_pos/data/repositories/category_repository.dart';
import 'package:street_cart_pos/data/repositories/modifier_repository.dart';
import 'package:street_cart_pos/data/repositories/product_repository.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';

class MenuRepository extends ChangeNotifier {
  static MenuRepository _instance = MenuRepository._internal();

  factory MenuRepository() => _instance;

  MenuRepository._internal();

  @visibleForTesting
  MenuRepository.testing();

  @visibleForTesting
  static void setInstance(MenuRepository instance) {
    _instance = instance;
  }

  Future<void> init() async {
    await _refreshData();
  }

  final _categoryRepository = CategoryRepository();
  final _productRepository = ProductRepository();
  final _modifierRepository = ModifierRepository();

  List<Category> _categories = [];
  List<ModifierGroup> _modifierGroups = [];
  List<Product> _products = [];

  List<Category> get categories => _categories;
  List<ModifierGroup> get modifierGroups => _modifierGroups;
  List<Product> get products => _products;

  Future<void> _refreshData() async {
    _categories = await _categoryRepository.getCategories();
    _products = await _productRepository.getProducts();
    _modifierGroups = await _modifierRepository.getGlobalModifierGroups();
    notifyListeners();
  }

  // Category Actions
  Future<void> addCategory(Category category) async {
    await _categoryRepository.saveCategory(category);
    await _refreshData();
  }

  Future<void> updateCategory(Category category) async {
    await _categoryRepository.saveCategory(category);
    await _refreshData();
  }

  Future<void> deleteCategory(String id) async {
    await _categoryRepository.deleteCategory(id);
    await _refreshData();
  }

  // Modifier Actions
  Future<void> addModifierGroup(ModifierGroup group) async {
    await _modifierRepository.saveModifierGroup(group);
    await _refreshData();
  }

  Future<void> updateModifierGroup(ModifierGroup group) async {
    await _modifierRepository.saveModifierGroup(group);
    await _refreshData();
  }

  Future<void> deleteModifierGroup(String id) async {
    await _modifierRepository.deleteModifierGroup(id);
    await _refreshData();
  }

  // Product Actions
  Future<void> addProduct(Product product) async {
    await _productRepository.createProduct(product);
    await _refreshData();
  }

  Future<void> updateProduct(Product product) async {
    await _productRepository.updateProduct(product);
    await _refreshData();
  }

  Future<void> deleteProduct(String id) async {
    await _productRepository.deleteProduct(id);
    await _refreshData();
  }

  @visibleForTesting
  Future<void> reset() async {
    // In tests, the DB is reset via AppDatabase.reset().
    // We just need to refresh our local cache to reflect the empty DB.
    _modifierGroups.clear();
    await _refreshData();
  }
}