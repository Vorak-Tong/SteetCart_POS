import '../local/app_database.dart';
import '../local/dao/modifier_dao.dart';
import '../../domain/models/product_model.dart';

class ModifierRepository {
  final _modifierDao = ModifierDao();

  Future<List<ModifierGroup>> getGlobalModifierGroups() async {
    final groupRows = await _modifierDao.getGlobalGroups();
    final List<ModifierGroup> groups = [];

    for (final row in groupRows) {
      final groupId = row[ModifierDao.colGroupId] as String;
      final optionRows = await _modifierDao.getOptionsByGroupId(groupId);

      final options = optionRows.map((optRow) {
        return ModifierOptions(
          id: optRow[ModifierDao.colOptionId] as String,
          name: optRow[ModifierDao.colOptionName] as String,
          price: (optRow[ModifierDao.colOptionPrice] as num?)?.toDouble(),
          isDefault: (optRow[ModifierDao.colOptionIsDefault] as int? ?? 0) == 1,
        );
      }).toList();

      groups.add(
        ModifierGroup(
          id: groupId,
          name: row[ModifierDao.colGroupName] as String,
          selectionType: ModifierSelectionType
              .values[row[ModifierDao.colSelectionType] as int? ?? 0],
          priceBehavior: ModifierPriceBehavior
              .values[row[ModifierDao.colPriceBehavior] as int? ?? 1],
          minSelection: row[ModifierDao.colMinSelection] as int? ?? 0,
          maxSelection: row[ModifierDao.colMaxSelection] as int? ?? 1,
          modifierOptions: options,
        ),
      );
    }

    return groups;
  }

  Future<void> saveModifierGroup(ModifierGroup group) async {
    final groupName = group.name.trim();
    if (groupName.isEmpty) {
      throw ArgumentError('Modifier group name cannot be empty.');
    }
    if (groupName.length > ModifierGroup.nameMax) {
      throw ArgumentError(
        'Modifier group name must be at most ${ModifierGroup.nameMax} characters.',
      );
    }
    if (group.modifierOptions.isEmpty) {
      throw ArgumentError('Modifier group must have at least one option.');
    }
    if (group.modifierOptions.length > ModifierGroup.maxOptionsPerGroup) {
      throw ArgumentError(
        'Modifier group can have at most ${ModifierGroup.maxOptionsPerGroup} options.',
      );
    }

    final db = await AppDatabase.instance();

    await db.transaction((txn) async {
      // Insert/Replace Group (Cascade delete will remove old options if group exists)
      await _modifierDao.insertGroup({
        ModifierDao.colGroupId: group.id,
        ModifierDao.colGroupName: groupName,
        ModifierDao.colSelectionType: group.selectionType.index,
        ModifierDao.colPriceBehavior: group.priceBehavior.index,
        ModifierDao.colMinSelection: group.minSelection,
        ModifierDao.colMaxSelection: group.maxSelection,
      }, txn: txn);

      await _modifierDao.deleteOptionsByGroupId(group.id, txn: txn);

      // Insert Options
      for (final option in group.modifierOptions) {
        final optionName = option.name.trim();
        if (optionName.isEmpty) {
          throw ArgumentError('Modifier option name cannot be empty.');
        }
        if (optionName.length > ModifierOptions.nameMax) {
          throw ArgumentError(
            'Modifier option name must be at most ${ModifierOptions.nameMax} characters.',
          );
        }
        final price = group.priceBehavior == ModifierPriceBehavior.none
            ? null
            : (option.price ?? 0.0);
        if (price != null && price < 0) {
          throw ArgumentError('Modifier option price cannot be negative.');
        }

        await _modifierDao.insertOption({
          ModifierDao.colOptionId: option.id,
          ModifierDao.colOptionName: optionName,
          ModifierDao.colOptionPrice: price,
          ModifierDao.colOptionIsDefault: option.isDefault ? 1 : 0,
          ModifierDao.colOptionGroupId: group.id,
        }, txn: txn);
      }
    });
  }

  Future<void> deleteModifierGroup(String id) async {
    // Cascade delete in DB will handle options
    await _modifierDao.deleteGroup(id);
  }
}
