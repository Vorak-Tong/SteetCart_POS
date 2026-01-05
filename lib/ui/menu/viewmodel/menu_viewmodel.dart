import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';

class MenuViewModel extends ChangeNotifier {
  final MenuRepository _repository = MenuRepository();
  final Set<String> _pendingRemoveIds = {};
  bool _disposed = false;

  MenuViewModel() {
    _repository.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _disposed = true;
    _repository.removeListener(notifyListeners);
    super.dispose();
  }

  static const String allCategoryId = '__all__';
  static const String uncategorizedCategoryId = '__uncategorized__';
  static const String archivedCategoryId = '__archived__';

  String _selectedCategoryId = allCategoryId;
  String _searchQuery = '';

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

  Future<void> addProduct(Product product) async {
    await _repository.addProduct(product);
  }

  Future<void> updateProduct(Product product) async {
    await _repository.updateProduct(product);
  }

  Future<void> deleteProduct(Product product) async {
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

  Future<void> archiveProduct(Product product) async {
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

  Future<void> unarchiveProduct(Product product) async {
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
