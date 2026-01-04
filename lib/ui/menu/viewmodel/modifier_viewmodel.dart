import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import 'package:uuid/uuid.dart';

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

  Future<void> addModifierGroup(String name, int optionCount) async {
    // Create dummy options to match the count returned by the form
    final options = List.generate(
      optionCount,
      (index) => ModifierOptions(
        id: const Uuid().v4(),
        name: 'Option ${index + 1}',
      ),
    );

    await _repository.addModifierGroup(ModifierGroup(
      id: const Uuid().v4(),
      name: name,
      modifierOptions: options,
    ));
  }

  Future<void> updateModifierGroup(ModifierGroup group, String name, int optionCount) async {
    final options = List.generate(
      optionCount,
      (index) => ModifierOptions(
        id: const Uuid().v4(),
        name: 'Option ${index + 1}',
      ),
    );

    await _repository.updateModifierGroup(ModifierGroup(
      id: group.id,
      name: name,
      modifierOptions: options,
    ));
  }

  Future<void> deleteModifierGroup(ModifierGroup group) async {
    await _repository.deleteModifierGroup(group.id);
  }
}