import 'model_ids.dart';
import 'order_modifier_selection.dart';
import 'product.dart';

class OrderProduct {
  final String id;
  final int quantity;

  final Product? product;
  final List<OrderModifierSelection> modifierSelections;
  final String? note;

  OrderProduct({
    String? id,
    required this.quantity,
    this.product,
    this.modifierSelections = const [],
    this.note,
  }) : id = id ?? uuid.v4();

  double getLineTotal() {
    if (product != null) {
      return product!.basePrice * quantity;
    }
    return 0.0;
  }
}
