import 'package:sqflite/sqflite.dart';
import '../app_database.dart';

class ProductDao {
  static const tableName = 'products';

  // Column names
  static const colId = 'id';
  static const colName = 'name';
  static const colDescription = 'description';
  static const colBasePrice = 'base_price';
  static const colImage = 'image';
  static const colIsActive = 'is_active';
  static const colCategoryId = 'category_id';

  Future<List<Map<String, Object?>>> getAll({
    bool includeInactive = true,
  }) async {
    final db = await AppDatabase.instance();
    if (includeInactive) {
      return await db.query(tableName);
    }
    return await db.query(tableName, where: '$colIsActive = 1');
  }

  Future<Map<String, Object?>?> getById(String id) async {
    final db = await AppDatabase.instance();
    final results = await db.query(
      tableName,
      where: '$colId = ?',
      whereArgs: [id],
    );

    return results.isNotEmpty ? results.first : null;
  }

  Future<int> insert(Map<String, Object?> data, {Transaction? txn}) async {
    final DatabaseExecutor db = txn ?? await AppDatabase.instance();
    return await db.insert(
      tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(Map<String, Object?> data, {Transaction? txn}) async {
    final DatabaseExecutor db = txn ?? await AppDatabase.instance();
    final id = data[colId];
    return await db.update(
      tableName,
      data,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(String id, {Transaction? txn}) async {
    final DatabaseExecutor db = txn ?? await AppDatabase.instance();
    return await db.delete(tableName, where: '$colId = ?', whereArgs: [id]);
  }
}
