import 'package:flutter_test/flutter_test.dart';
import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/modifier_viewmodel.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import '../../../helpers/fake_menu_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  late ModifierViewModel viewModel;

  setUp(() async {
    MenuRepository.setInstance(FakeMenuRepository());
    
    final repo = MenuRepository();
    await repo.addModifierGroup(ModifierGroup(id: const Uuid().v4(), name: 'Ice Level', modifierOptions: [ModifierOptions(id: const Uuid().v4(), name: 'Option 1'), ModifierOptions(id: const Uuid().v4(), name: 'Option 2'), ModifierOptions(id: const Uuid().v4(), name: 'Option 3'), ModifierOptions(id: const Uuid().v4(), name: 'Option 4')]));
    await repo.addModifierGroup(ModifierGroup(id: const Uuid().v4(), name: 'Sugar Level'));
    await repo.addModifierGroup(ModifierGroup(id: const Uuid().v4(), name: 'Size'));
    await repo.addModifierGroup(ModifierGroup(id: const Uuid().v4(), name: 'Toppings'));

    viewModel = ModifierViewModel();
  });

  test('Initial state loads modifiers from repository', () {
    // Mock data has 4 groups (Ice, Sugar, Size, Toppings)
    expect(viewModel.modifierGroups.length, 4);
  });

  test('addModifierGroup adds group with correct option count', () {
    viewModel.addModifierGroup('Spiciness', 3);

    expect(viewModel.modifierGroups.length, 5);
    final newGroup = viewModel.modifierGroups.last;
    expect(newGroup.name, 'Spiciness');
    expect(newGroup.modifierOptions.length, 3);
    expect(newGroup.modifierOptions[0].name, 'Option 1');
  });

  test('updateModifierGroup updates name and regenerates options', () {
    final group = viewModel.modifierGroups.first; // Ice Level (4 options)
    
    // Update to 2 options
    viewModel.updateModifierGroup(group, 'Ice Amount', 2);

    final updated = viewModel.modifierGroups.firstWhere((g) => g.id == group.id);
    expect(updated.name, 'Ice Amount');
    expect(updated.modifierOptions.length, 2);
  });

  test('deleteModifierGroup removes group', () {
    final group = viewModel.modifierGroups.first;
    
    viewModel.deleteModifierGroup(group);

    expect(viewModel.modifierGroups.length, 3);
    expect(
      viewModel.modifierGroups.any((g) => g.id == group.id),
      isFalse,
    );
  });
}
