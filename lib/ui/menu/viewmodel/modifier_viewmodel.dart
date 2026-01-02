import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';

class ModifierViewModel extends ChangeNotifier {
  final MenuRepository _repository = MenuRepository();

  ModifierViewModel() {
    _repository.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _repository.removeListener(notifyListeners);
    super.dispose();
  }

  List<ModifierGroup> get modifierGroups => List.unmodifiable(_repository.modifierGroups);

  void addModifierGroup(String name, int optionCount) {
    // Create dummy options to match the count returned by the form
    final options = List.generate(
      optionCount,
      (index) => ModifierOptions(name: 'Option ${index + 1}'),
    );

    _repository.addModifierGroup(ModifierGroup(
      name: name,
      modifierOptions: options,
    ));
  }

  void updateModifierGroup(ModifierGroup group, String name, int optionCount) {
    final options = List.generate(
      optionCount,
      (index) => ModifierOptions(name: 'Option ${index + 1}'),
    );

    _repository.updateModifierGroup(ModifierGroup(
      id: group.id,
      name: name,
      modifierOptions: options,
    ));
  }

  void deleteModifierGroup(ModifierGroup group) {
    _repository.deleteModifierGroup(group.id);
  }
}