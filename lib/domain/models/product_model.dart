import 'package:uuid/uuid.dart';

const uuid = Uuid();

// Category Class
class Category {
  final String id;
  final String name;

  Category({
    String? id,
    required this.name,
  }) : id = id ?? uuid.v4();
  
}

// Modifiers
class ModifierOptions {
  final String id;
  final String name;
  final double? price;

  ModifierOptions({
    String? id,
    required this.name,
    this.price,
  }) : id = id ?? uuid.v4();
}

class ModifierGroup {
  final String id;
  final String name;
  
  final List<ModifierOptions> modifierOptions;

  ModifierGroup({
    String? id,
    required this.name,
    this.modifierOptions = const [],
  }) : id = id ?? uuid.v4();
}

// 3. Product 
class Product {
  final String id;
  final String name;
  final double basePrice;
  final String? image;
  
  final Category? category; 
  
  final List<ModifierGroup> modifierGroups;

  Product({
    String? id,
    required this.name,
    required this.basePrice,
    this.image,
    this.category,
    this.modifierGroups = const [],
  }) : id = id ?? uuid.v4();

  void createProduct() {}
  void deleteProduct() {}
  void updateProduct() {}
}