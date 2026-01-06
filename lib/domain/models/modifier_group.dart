import 'model_ids.dart';
import 'modifier_enums.dart';
import 'modifier_option.dart';

class ModifierGroup {
  static const int nameMax = 20;
  static const int maxOptionsPerGroup = 10;

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
