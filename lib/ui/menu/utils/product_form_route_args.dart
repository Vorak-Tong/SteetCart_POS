import 'package:street_cart_pos/domain/models/category.dart';
import 'package:street_cart_pos/domain/models/modifier_group.dart';
import 'package:street_cart_pos/domain/models/product.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/product_form_viewmodel.dart';

class ProductFormRouteArgs {
  const ProductFormRouteArgs({
    required this.mode,
    required this.categories,
    required this.availableModifiers,
    this.initialProduct,
    this.onSave,
  });

  final ProductFormMode mode;
  final List<Category> categories;
  final List<ModifierGroup> availableModifiers;
  final Product? initialProduct;
  final Future<void> Function(Product product)? onSave;
}

