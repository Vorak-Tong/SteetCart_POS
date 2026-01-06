import 'category.dart';
import 'model_ids.dart';
import 'modifier_group.dart';

class Product {
  static const int nameMax = 20;
  static const int descriptionMax = 80;

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
}
