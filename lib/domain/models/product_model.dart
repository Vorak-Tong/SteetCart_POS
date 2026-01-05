import 'package:uuid/uuid.dart';

const uuid = Uuid();

enum ModifierSelectionType { single, multi }

enum ModifierPriceBehavior { fixed, none }

// Category Class
class Category {
  final String id;
  final String name;

  Category({String? id, required this.name}) : id = id ?? uuid.v4();
}

// Modifiers
class ModifierOptions {
  final String id;
  final String name;
  final double? price;
  final bool isDefault;

  ModifierOptions({
    String? id,
    required this.name,
    this.price,
    this.isDefault = false,
  }) : id = id ?? uuid.v4();
}

class ModifierGroup {
  final String id;
  final String name;
  final ModifierSelectionType selectionType;
  final ModifierPriceBehavior priceBehavior;
  final int minSelection;
  final int maxSelection;

  final List<ModifierOptions> modifierOptions;

  ModifierGroup({
    String? id,
    required this.name,
    this.selectionType = ModifierSelectionType.single,
    this.priceBehavior = ModifierPriceBehavior.none,
    this.minSelection = 0,
    this.maxSelection = 1,
    this.modifierOptions = const [],
  }) : id = id ?? uuid.v4();
}

// 3. Product
class Product {
  final String id;
  final String name;
  final String? description;
  final double basePrice;
  final String? imagePath;
  final bool isActive;

  final Category? category;

  final List<ModifierGroup> modifierGroups;

  Product({
    String? id,
    required this.name,
    this.description,
    required this.basePrice,
    this.imagePath,
    this.isActive = true,
    this.category,
    this.modifierGroups = const [],
  }) : id = id ?? uuid.v4();

  void createProduct() {}
  void deleteProduct() {}
  void updateProduct() {}
}
