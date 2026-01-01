import 'package:sqflite/sqflite.dart';
import '../app_database.dart';

class OrderItemDao {
  static const tableName = 'order_items';

  // Columns
  static const colId = 'id';
  static const colOrderId = 'order_id'; // Foreign Key to orders
  static const colProductId = 'product_id'; // Foreign Key to products
  static const colQuantity = 'quantity';

  // Get items for a specific order
  Future<List<Map<String, Object?>>> getByOrderId(String orderId) async {
    final db = await AppDatabase.instance();
    return await db.query(
      tableName,
      where: '$colOrderId = ?',
      whereArgs: [orderId],
    );
  }

  // Insert a single item (usually part of a batch/transaction)
  Future<int> insert(Map<String, Object?> data, {Transaction? txn}) async {
    final DatabaseExecutor db = txn ?? await AppDatabase.instance();
    return await db.insert(
      tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Delete items for an order (useful when clearing/updating an order)
  Future<int> deleteByOrderId(String orderId, {Transaction? txn}) async {
    final DatabaseExecutor db = txn ?? await AppDatabase.instance();
    return await db.delete(
      tableName,
      where: '$colOrderId = ?',
      whereArgs: [orderId],
    );
  }
}