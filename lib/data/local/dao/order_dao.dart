import 'package:sqflite/sqflite.dart';
import '../app_database.dart';

class OrderDao {
  static const tableName = 'orders';

  // Column names
  static const colId = 'id';
  static const colTimeStamp = 'timestamp';
  static const colOrderType = 'order_type';
  static const colPaymentType = 'payment_type';
  static const colStatus = 'status';

  Future<List<Map<String, Object?>>> getAll() async {
    final db = await AppDatabase.instance();
    return await db.query(tableName, orderBy: '$colTimeStamp DESC');
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
    return await db.delete(
      tableName,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }
}