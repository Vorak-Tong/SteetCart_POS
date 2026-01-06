import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/domain/models/category.dart';
import 'package:street_cart_pos/domain/models/modifier_group.dart';
import 'package:street_cart_pos/domain/models/product.dart';
import 'package:street_cart_pos/utils/command.dart';

class MenuViewModel extends ChangeNotifier {
  final MenuRepository _repository = MenuRepository();
  final Set<String> _pendingRemoveIds = {};
  bool _disposed = false;
  bool _hasLoadedOnce = false;

  late final CommandWithParam<void, void> loadMenuCommand;
  late final CommandWithParam<Product, void> addProductCommand;
  late final CommandWithParam<Product, void> updateProductCommand;
  late final CommandWithParam<Product, void> _deleteProductCommand;
  late final CommandWithParam<Product, void> _archiveProductCommand;
  late final CommandWithParam<Product, void> _unarchiveProductCommand;

  MenuViewModel() {
    _repository.addListener(notifyListeners);

    loadMenuCommand = CommandWithParam((_) => _loadMenu());
    addProductCommand = CommandWithParam(_addProduct);
    updateProductCommand = CommandWithParam(_updateProduct);
    _deleteProductCommand = CommandWithParam(_deleteProduct);
    _archiveProductCommand = CommandWithParam(_archiveProduct);
    _unarchiveProductCommand = CommandWithParam(_unarchiveProduct);

    loadMenuCommand.addListener(notifyListeners);
    addProductCommand.addListener(notifyListeners);
    updateProductCommand.addListener(notifyListeners);
    _deleteProductCommand.addListener(notifyListeners);
    _archiveProductCommand.addListener(notifyListeners);
    _unarchiveProductCommand.addListener(notifyListeners);

    loadMenuCommand.execute(null);
  }

  @override
  void dispose() {
    _disposed = true;
    _repository.removeListener(notifyListeners);
    loadMenuCommand.removeListener(notifyListeners);
    addProductCommand.removeListener(notifyListeners);
    updateProductCommand.removeListener(notifyListeners);
    _deleteProductCommand.removeListener(notifyListeners);
    _archiveProductCommand.removeListener(notifyListeners);
    _unarchiveProductCommand.removeListener(notifyListeners);
    super.dispose();
  }

  static const String allCategoryId = '__all__';
  static const String uncategorizedCategoryId = '__uncategorized__';
  static const String archivedCategoryId = '__archived__';

  String _selectedCategoryId = allCategoryId;
  String _searchQuery = '';

  bool get loading => loadMenuCommand.running;
  bool get hasLoadedOnce => _hasLoadedOnce;

  // Getters
  List<Product> get products => List.unmodifiable(
    _repository.products.where((p) => !_pendingRemoveIds.contains(p.id)),
  );
  List<Category> get categories => List.unmodifiable(_repository.categories);
  List<ModifierGroup> get modifierGroups =>
      List.unmodifiable(_repository.modifierGroups);

  String get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;

  List<Product> get filteredProducts {
    final query = _searchQuery.trim().toLowerCase();
    return products.where((p) {
      final matchesCategory = switch (_selectedCategoryId) {
        allCategoryId => p.isActive,
        uncategorizedCategoryId => p.isActive && p.category == null,
        archivedCategoryId => !p.isActive,
        _ => p.isActive && p.category?.id == _selectedCategoryId,
      };

      final matchesSearch =
          query.isEmpty || p.name.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  // Actions
  Future<void> refreshFromDb() => loadMenuCommand.execute(null);

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

  Future<void> addProduct(Product product) =>
      addProductCommand.execute(product);

  Future<void> updateProduct(Product product) =>
      updateProductCommand.execute(product);

  Future<void> deleteProduct(Product product) =>
      _deleteProductCommand.execute(product);

  Future<void> archiveProduct(Product product) =>
      _archiveProductCommand.execute(product);

  Future<void> unarchiveProduct(Product product) =>
      _unarchiveProductCommand.execute(product);

  Future<void> _loadMenu() async {
    await _repository.init();
    _hasLoadedOnce = true;
    notifyListeners();
  }

  Future<void> _addProduct(Product product) async {
    await _repository.addProduct(product);
  }

  Future<void> _updateProduct(Product product) async {
    await _repository.updateProduct(product);
  }

  Future<void> _deleteProduct(Product product) async {
    if (_pendingRemoveIds.contains(product.id)) return;
    _pendingRemoveIds.add(product.id);
    if (!_disposed) notifyListeners();
    try {
      await _repository.deleteProduct(product.id);
    } catch (_) {
      _pendingRemoveIds.remove(product.id);
      if (!_disposed) notifyListeners();
      rethrow;
    } finally {
      _pendingRemoveIds.remove(product.id);
    }
  }

  Future<void> _archiveProduct(Product product) async {
    if (_pendingRemoveIds.contains(product.id)) return;
    _pendingRemoveIds.add(product.id);
    if (!_disposed) notifyListeners();
    try {
      await _repository.archiveProduct(product.id);
    } catch (_) {
      _pendingRemoveIds.remove(product.id);
      if (!_disposed) notifyListeners();
      rethrow;
    } finally {
      _pendingRemoveIds.remove(product.id);
    }
  }

  Future<void> _unarchiveProduct(Product product) async {
    if (_pendingRemoveIds.contains(product.id)) return;
    _pendingRemoveIds.add(product.id);
    if (!_disposed) notifyListeners();
    try {
      await _repository.unarchiveProduct(product.id);
    } catch (_) {
      _pendingRemoveIds.remove(product.id);
      if (!_disposed) notifyListeners();
      rethrow;
    } finally {
      _pendingRemoveIds.remove(product.id);
    }
  }
}
