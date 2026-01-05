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
    final db = await AppDatabase.instance();

    await db.transaction((txn) async {
      // Insert/Replace Group (Cascade delete will remove old options if group exists)
      await _modifierDao.insertGroup({
        ModifierDao.colGroupId: group.id,
        ModifierDao.colGroupName: group.name,
        ModifierDao.colSelectionType: group.selectionType.index,
        ModifierDao.colPriceBehavior: group.priceBehavior.index,
        ModifierDao.colMinSelection: group.minSelection,
        ModifierDao.colMaxSelection: group.maxSelection,
      }, txn: txn);

      await _modifierDao.deleteOptionsByGroupId(group.id, txn: txn);

      // Insert Options
      for (final option in group.modifierOptions) {
        await _modifierDao.insertOption({
          ModifierDao.colOptionId: option.id,
          ModifierDao.colOptionName: option.name,
          ModifierDao.colOptionPrice: option.price,
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
