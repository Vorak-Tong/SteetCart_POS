import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/domain/models/category.dart';
import 'package:street_cart_pos/domain/models/modifier_group.dart';
import 'package:street_cart_pos/domain/models/product.dart';

class FakeMenuRepository extends MenuRepository {
  FakeMenuRepository() : super.testing();

  final List<Category> _categories = [];
  final List<Product> _products = [];
  final List<ModifierGroup> _modifierGroups = [];

  @override
  List<Category> get categories => List.unmodifiable(_categories);
  @override
  List<Product> get products => List.unmodifiable(_products);
  @override
  List<ModifierGroup> get modifierGroups => List.unmodifiable(_modifierGroups);

  @override
  Future<void> init() async {}

  @override
  Future<void> addCategory(Category category) async {
    _categories.add(category);
    notifyListeners();
  }

  @override
  Future<void> updateCategory(Category category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      notifyListeners();
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  @override
  Future<void> addModifierGroup(ModifierGroup group) async {
    _modifierGroups.add(group);
    notifyListeners();
  }

  @override
  Future<void> updateModifierGroup(ModifierGroup group) async {
    final index = _modifierGroups.indexWhere((g) => g.id == group.id);
    if (index != -1) {
      _modifierGroups[index] = group;
      notifyListeners();
    }
  }

  @override
  Future<void> deleteModifierGroup(String id) async {
    _modifierGroups.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  @override
  Future<void> addProduct(Product product) async {
    _products.add(product);
    notifyListeners();
  }

  @override
  Future<void> updateProduct(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  @override
  Future<void> reset() async {
    _categories.clear();
    _products.clear();
    _modifierGroups.clear();
    notifyListeners();
  }
}
