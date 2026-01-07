import 'package:flutter/foundation.dart' show ChangeNotifier, debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:street_cart_pos/domain/models/category.dart';
import 'package:street_cart_pos/domain/models/modifier_group.dart';
import 'package:street_cart_pos/domain/models/product.dart';
import 'package:street_cart_pos/ui/core/utils/persist_image_path.dart';
import 'package:street_cart_pos/utils/command.dart';

enum ProductFormMode { create, view, edit }

class ProductFormViewModel extends ChangeNotifier {
  ProductFormViewModel({
    required ProductFormMode mode,
    required List<Category> categories,
    required List<ModifierGroup> availableModifiers,
    required this.onSave,
    Product? initialProduct,
  }) : _categories = List.unmodifiable(categories),
       _availableModifiers = List.unmodifiable(availableModifiers),
       _initialProduct = initialProduct,
       _mode = mode {
    if (_mode != ProductFormMode.create) assert(initialProduct != null);

    final product = initialProduct;
    if (product != null) _loadFrom(product);

    nameController.addListener(notifyListeners);
    descriptionController.addListener(notifyListeners);
    priceController.addListener(notifyListeners);

    pickImageCommand = CommandWithParam((_) => _pickImage());
    saveCommand = CommandWithParam((_) => _save());

    pickImageCommand.addListener(notifyListeners);
    saveCommand.addListener(notifyListeners);
  }

  final Future<void> Function(Product product)? onSave;

  final List<Category> _categories;
  final List<ModifierGroup> _availableModifiers;
  Product? _initialProduct;
  ProductFormMode _mode;

  ProductFormMode get mode => _mode;

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  String? selectedCategoryId;
  final List<ModifierGroup> selectedModifiers = [];
  String? imagePath;

  late final CommandWithParam<void, void> pickImageCommand;
  late final CommandWithParam<void, void> saveCommand;

  bool get isReadOnly => _mode == ProductFormMode.view;
  bool get isEditing => _mode == ProductFormMode.edit;

  String get title => switch (mode) {
    ProductFormMode.create => 'Add New Product',
    ProductFormMode.edit => 'Edit Product',
    ProductFormMode.view => 'Product Details',
  };

  bool get hasImage => imagePath != null && imagePath!.trim().isNotEmpty;

  bool get priceValid {
    final value = double.tryParse(priceController.text.trim());
    return value != null && value > 0;
  }

  bool get formValid => nameController.text.trim().isNotEmpty && priceValid;

  bool get canSave => !isReadOnly && formValid && !saveCommand.running;

  List<ModifierGroup> get unselectedModifiers => _availableModifiers
      .where((m) => !selectedModifiers.any((x) => x.id == m.id))
      .toList(growable: false);

  void enterEdit() {
    if (_mode != ProductFormMode.view) return;
    _mode = ProductFormMode.edit;
    notifyListeners();
  }

  void cancelEdit() {
    if (_mode != ProductFormMode.edit) return;
    final initial = _initialProduct;
    if (initial != null) {
      _loadFrom(initial);
    }
    _mode = ProductFormMode.view;
    notifyListeners();
  }

  void setSelectedCategoryId(String? id) {
    if (selectedCategoryId == id) return;
    selectedCategoryId = id;
    notifyListeners();
  }

  void addModifier(ModifierGroup group) {
    if (selectedModifiers.any((x) => x.id == group.id)) return;
    selectedModifiers.add(group);
    notifyListeners();
  }

  void removeModifier(ModifierGroup group) {
    selectedModifiers.removeWhere((x) => x.id == group.id);
    notifyListeners();
  }

  void clearImage() {
    if (!hasImage) return;
    imagePath = null;
    notifyListeners();
  }

  Future<void> pickImage() => pickImageCommand.execute(null);

  Future<void> save() => saveCommand.execute(null);

  Category? _resolveCategory() {
    final id = selectedCategoryId;
    if (id == null) return null;
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  void _loadFrom(Product product) {
    nameController.text = product.name;
    descriptionController.text = product.description ?? '';
    priceController.text = product.basePrice.toString();
    selectedCategoryId = product.category?.id;
    imagePath = product.imagePath;

    selectedModifiers
      ..clear()
      ..addAll(
        _availableModifiers.where(
          (m) => product.modifierGroups.any((g) => g.id == m.id),
        ),
      );
  }

  Future<void> _pickImage() async {
    if (isReadOnly) return;

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      if (kIsWeb) {
        imagePath = picked.path;
        notifyListeners();
        return;
      }

      final persistedPath = await persistImagePath(picked.path);
      imagePath = persistedPath;
      notifyListeners();
    } catch (e, st) {
      debugPrint('Image pick failed: $e\n$st');
      rethrow;
    }
  }

  Future<void> _save() async {
    if (isReadOnly) return;
    if (!formValid) return;
    if (onSave == null) return;

    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final price = double.tryParse(priceController.text.trim());
    if (price == null || price <= 0) return;

    final initial = _initialProduct;
    final product = Product(
      id: initial?.id,
      name: name,
      description: description.isEmpty ? null : description,
      basePrice: price,
      category: _resolveCategory(),
      modifierGroups: List.unmodifiable(selectedModifiers),
      imagePath: imagePath,
      isActive: initial?.isActive ?? true,
    );

    await onSave!(product);
    _initialProduct = product;
    if (_mode == ProductFormMode.edit) {
      _mode = ProductFormMode.view;
    }
  }

  @override
  void dispose() {
    pickImageCommand.removeListener(notifyListeners);
    saveCommand.removeListener(notifyListeners);

    nameController.removeListener(notifyListeners);
    descriptionController.removeListener(notifyListeners);
    priceController.removeListener(notifyListeners);

    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }
}
