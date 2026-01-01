import 'package:sqflite/sqflite.dart';
import '../app_database.dart';

class ModifierDao {
  static const tableGroups = 'modifier_groups';
  static const tableOptions = 'modifier_options';

  // Group Columns
  static const colGroupId = 'id';
  static const colGroupName = 'name';
  static const colGroupProductId = 'product_id'; // FK to products

  // Option Columns
  static const colOptionId = 'id';
  static const colOptionName = 'name';
  static const colOptionPrice = 'price';
  static const colOptionGroupId = 'group_id'; // FK to modifier_groups

  // ---------------------------------------------------------------------------
  // Modifier Groups
  // ---------------------------------------------------------------------------

  Future<List<Map<String, Object?>>> getGroupsByProductId(String productId) async {
    final db = await AppDatabase.instance();
    return await db.query(
      tableGroups,
      where: '$colGroupProductId = ?',
      whereArgs: [productId],
    );
  }

  Future<int> insertGroup(Map<String, Object?> data, {Transaction? txn}) async {
    final DatabaseExecutor db = txn ?? await AppDatabase.instance();
    return await db.insert(
      tableGroups,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteGroupsByProductId(String productId, {Transaction? txn}) async {
    final DatabaseExecutor db = txn ?? await AppDatabase.instance();
    return await db.delete(
      tableGroups,
      where: '$colGroupProductId = ?',
      whereArgs: [productId],
    );
  }

  // ---------------------------------------------------------------------------
  // Modifier Options
  // ---------------------------------------------------------------------------

  Future<List<Map<String, Object?>>> getOptionsByGroupId(String groupId) async {
    final db = await AppDatabase.instance();
    return await db.query(
      tableOptions,
      where: '$colOptionGroupId = ?',
      whereArgs: [groupId],
    );
  }

  Future<int> insertOption(Map<String, Object?> data, {Transaction? txn}) async {
    final DatabaseExecutor db = txn ?? await AppDatabase.instance();
    return await db.insert(
      tableOptions,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteOptionsByGroupId(String groupId, {Transaction? txn}) async {
    final DatabaseExecutor db = txn ?? await AppDatabase.instance();
    return await db.delete(
      tableOptions,
      where: '$colOptionGroupId = ?',
      whereArgs: [groupId],
    );
  }
  
  // Helper to delete everything related to a product (useful for updates/deletes)
  // Note: If Foreign Keys are set to ON DELETE CASCADE, this might happen automatically,
  // but explicit deletion is safer if we aren't sure about the SQLite config.
  Future<void> deleteModifiersForProduct(String productId, {Transaction? txn}) async {
    // We need to find groups first to delete their options
    // Or rely on CASCADE. Assuming manual for safety here:
    final groups = await (txn != null 
        ? txn.query(tableGroups, where: '$colGroupProductId = ?', whereArgs: [productId])
        : getGroupsByProductId(productId));
        
    for (final group in groups) {
      await deleteOptionsByGroupId(group[colGroupId] as String, txn: txn);
    }
    await deleteGroupsByProductId(productId, txn: txn);
  }
}