import 'package:sqflite/sqflite.dart';
import '../app_database.dart';

class ProductModifierGroupDao {
  static const tableName = 'product_modifier_groups';

  static const colProductId = 'product_id';
  static const colGroupId = 'group_id';

  Future<List<String>> getGroupIdsByProductId(String productId) async {
    final db = await AppDatabase.instance();
    final rows = await db.query(
      tableName,
      columns: [colGroupId],
      where: '$colProductId = ?',
      whereArgs: [productId],
    );
    return rows
        .map((row) => row[colGroupId])
        .whereType<String>()
        .toList(growable: false);
  }

  Future<void> replaceGroupIdsForProduct(
    String productId,
    List<String> groupIds, {
    Transaction? txn,
  }) async {
    final DatabaseExecutor db = txn ?? await AppDatabase.instance();

    await db.delete(
      tableName,
      where: '$colProductId = ?',
      whereArgs: [productId],
    );

    for (final groupId in groupIds) {
      await db.insert(tableName, {
        colProductId: productId,
        colGroupId: groupId,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }
}
