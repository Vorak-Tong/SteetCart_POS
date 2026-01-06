import 'package:flutter_test/flutter_test.dart';
import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/modifier_viewmodel.dart';
import 'package:street_cart_pos/domain/models/modifier_group.dart';
import 'package:street_cart_pos/domain/models/modifier_option.dart';
import '../../../helpers/fake_menu_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  late ModifierViewModel viewModel;

  setUp(() async {
    MenuRepository.setInstance(FakeMenuRepository());

    final repo = MenuRepository();
    await repo.addModifierGroup(
      ModifierGroup(
        id: const Uuid().v4(),
        name: 'Ice Level',
        modifierOptions: [
          ModifierOptions(id: const Uuid().v4(), name: 'Option 1'),
          ModifierOptions(id: const Uuid().v4(), name: 'Option 2'),
          ModifierOptions(id: const Uuid().v4(), name: 'Option 3'),
          ModifierOptions(id: const Uuid().v4(), name: 'Option 4'),
        ],
      ),
    );
    await repo.addModifierGroup(
      ModifierGroup(id: const Uuid().v4(), name: 'Sugar Level'),
    );
    await repo.addModifierGroup(
      ModifierGroup(id: const Uuid().v4(), name: 'Size'),
    );
    await repo.addModifierGroup(
      ModifierGroup(id: const Uuid().v4(), name: 'Toppings'),
    );

    viewModel = ModifierViewModel();
  });

  test('Initial state loads modifiers from repository', () {
    // Mock data has 4 groups (Ice, Sugar, Size, Toppings)
    expect(viewModel.modifierGroups.length, 4);
  });

  test('addModifierGroup adds group with correct option count', () async {
    await viewModel.addModifierGroup(
      ModifierGroup(
        id: const Uuid().v4(),
        name: 'Spiciness',
        modifierOptions: [
          ModifierOptions(id: const Uuid().v4(), name: 'Mild'),
          ModifierOptions(id: const Uuid().v4(), name: 'Medium'),
          ModifierOptions(id: const Uuid().v4(), name: 'Hot'),
        ],
      ),
    );

    expect(viewModel.modifierGroups.length, 5);
    final newGroup = viewModel.modifierGroups.last;
    expect(newGroup.name, 'Spiciness');
    expect(newGroup.modifierOptions.length, 3);
    expect(newGroup.modifierOptions[0].name, 'Mild');
  });

  test('updateModifierGroup updates name and options', () async {
    final group = viewModel.modifierGroups.first; // Ice Level (4 options)

    await viewModel.updateModifierGroup(
      ModifierGroup(
        id: group.id,
        name: 'Ice Amount',
        modifierOptions: [
          ModifierOptions(id: const Uuid().v4(), name: 'Less ice'),
          ModifierOptions(id: const Uuid().v4(), name: 'Normal ice'),
        ],
      ),
    );

    final updated = viewModel.modifierGroups.firstWhere(
      (g) => g.id == group.id,
    );
    expect(updated.name, 'Ice Amount');
    expect(updated.modifierOptions.length, 2);
  });

  test('deleteModifierGroup removes group', () async {
    final group = viewModel.modifierGroups.first;

    await viewModel.deleteModifierGroup(group);

    expect(viewModel.modifierGroups.length, 3);
    expect(viewModel.modifierGroups.any((g) => g.id == group.id), isFalse);
  });
}
