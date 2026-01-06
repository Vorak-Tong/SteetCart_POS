import 'model_ids.dart';

class ModifierOptions {
  static const int nameMax = 20;

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
