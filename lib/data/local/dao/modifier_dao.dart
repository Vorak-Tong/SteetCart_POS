import 'package:sqflite/sqflite.dart';
import '../app_database.dart';

class ModifierDao {
  static const tableGroups = 'modifier_groups';
  static const tableOptions = 'modifier_options';

  // Group Columns
  static const colGroupId = 'id';
  static const colGroupName = 'name';
  static const colSelectionType = 'selection_type';
  static const colPriceBehavior = 'price_behavior';
  static const colMinSelection = 'min_selection';
  static const colMaxSelection = 'max_selection';

  // Option Columns
  static const colOptionId = 'id';
  static const colOptionName = 'name';
  static const colOptionPrice = 'price';
  static const colOptionIsDefault = 'is_default';
  static const colOptionGroupId = 'group_id'; // FK to modifier_groups

  // ---------------------------------------------------------------------------
  // Modifier Groups
  // ---------------------------------------------------------------------------

  Future<List<Map<String, Object?>>> getGlobalGroups() async {
    final db = await AppDatabase.instance();
    return await db.query(tableGroups);
  }

  Future<List<Map<String, Object?>>> getAllGroups() async {
    final db = await AppDatabase.instance();
    return await db.query(tableGroups);
  }

  Future<List<Map<String, Object?>>> getGroupsByIds(
    List<String> groupIds, {
    Transaction? txn,
  }) async {
    if (groupIds.isEmpty) return const [];
    final DatabaseExecutor db = txn ?? await AppDatabase.instance();
    final placeholders = List.filled(groupIds.length, '?').join(', ');
    return await db.query(
      tableGroups,
      where: '$colGroupId IN ($placeholders)',
      whereArgs: groupIds,
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

  Future<int> deleteGroupsByProductId(
    String productId, {
    Transaction? txn,
  }) async {
    throw UnsupportedError(
      'Product-specific modifier groups are no longer supported.',
    );
  }

  Future<int> deleteGroup(String id, {Transaction? txn}) async {
    final DatabaseExecutor db = txn ?? await AppDatabase.instance();
    return await db.delete(
      tableGroups,
      where: '$colGroupId = ?',
      whereArgs: [id],
    );
  }

  // ---------------------------------------------------------------------------
  // Modifier Options
  // ---------------------------------------------------------------------------

  Future<List<Map<String, Object?>>> getOptionsByGroupId(
    String groupId, {
    Transaction? txn,
  }) async {
    final DatabaseExecutor db = txn ?? await AppDatabase.instance();
    return await db.query(
      tableOptions,
      where: '$colOptionGroupId = ?',
      whereArgs: [groupId],
    );
  }

  Future<int> insertOption(
    Map<String, Object?> data, {
    Transaction? txn,
  }) async {
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

  Future<void> deleteModifiersForProduct(
    String productId, {
    Transaction? txn,
  }) async {
    throw UnsupportedError(
      'Product-specific modifier groups are no longer supported.',
    );
  }
}
