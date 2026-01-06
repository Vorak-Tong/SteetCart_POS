import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/domain/models/category.dart';
import 'package:street_cart_pos/utils/command.dart';
import 'package:uuid/uuid.dart';

class CategoryViewModel extends ChangeNotifier {
  final MenuRepository _repository = MenuRepository();
  final Set<String> _pendingDeleteIds = {};
  bool _disposed = false;
  bool _hasLoadedOnce = false;

  late final CommandWithParam<void, void> loadMenuCommand;
  late final CommandWithParam<String, void> addCategoryCommand;
  late final CommandWithParam<_UpdateCategoryRequest, void>
  _updateCategoryCommand;
  late final CommandWithParam<Category, void> _deleteCategoryCommand;

  CategoryViewModel() {
    _repository.addListener(notifyListeners);

    loadMenuCommand = CommandWithParam((_) => _loadMenu());
    addCategoryCommand = CommandWithParam(_addCategory);
    _updateCategoryCommand = CommandWithParam(_updateCategory);
    _deleteCategoryCommand = CommandWithParam(_deleteCategory);

    loadMenuCommand.addListener(notifyListeners);
    addCategoryCommand.addListener(notifyListeners);
    _updateCategoryCommand.addListener(notifyListeners);
    _deleteCategoryCommand.addListener(notifyListeners);

    loadMenuCommand.execute(null);
  }

  @override
  void dispose() {
    _disposed = true;
    _repository.removeListener(notifyListeners);
    loadMenuCommand.removeListener(notifyListeners);
    addCategoryCommand.removeListener(notifyListeners);
    _updateCategoryCommand.removeListener(notifyListeners);
    _deleteCategoryCommand.removeListener(notifyListeners);
    super.dispose();
  }

  bool get loading => loadMenuCommand.running;
  bool get hasLoadedOnce => _hasLoadedOnce;
  bool get saving =>
      addCategoryCommand.running || _updateCategoryCommand.running;
  bool get deleting => _deleteCategoryCommand.running;

  List<Category> get categories => List.unmodifiable(
    _repository.categories.where((c) => !_pendingDeleteIds.contains(c.id)),
  );

  int getProductCountForCategory(String categoryId) {
    return _repository.products
        .where((p) => p.isActive && p.category?.id == categoryId)
        .length;
  }

  Future<void> addCategory(String name) async {
    await addCategoryCommand.execute(name);
  }

  Future<void> updateCategory(Category category, String newName) async {
    await _updateCategoryCommand.execute(
      _UpdateCategoryRequest(category: category, newName: newName),
    );
  }

  Future<void> deleteCategory(Category category) async {
    await _deleteCategoryCommand.execute(category);
  }

  Future<void> _loadMenu() async {
    await _repository.init();
    _hasLoadedOnce = true;
    notifyListeners();
  }

  Future<void> _addCategory(String name) async {
    await _repository.addCategory(Category(id: const Uuid().v4(), name: name));
  }

  Future<void> _updateCategory(_UpdateCategoryRequest request) async {
    await _repository.updateCategory(
      Category(id: request.category.id, name: request.newName),
    );
  }

  Future<void> _deleteCategory(Category category) async {
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

class _UpdateCategoryRequest {
  const _UpdateCategoryRequest({required this.category, required this.newName});

  final Category category;
  final String newName;
}
