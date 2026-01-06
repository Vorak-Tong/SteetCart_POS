import 'package:sqflite/sqflite.dart';
import '../app_database.dart';

class OrderItemDao {
  static const tableName = 'order_items';

  // Columns
  static const colId = 'id';
  static const colOrderId = 'order_id'; // Foreign Key to orders
  static const colProductId = 'product_id'; // Foreign Key to products
  static const colProductName = 'product_name';
  static const colUnitPrice = 'unit_price';
  static const colProductImage = 'product_image';
  static const colProductDescription = 'product_description';
  static const colModifierSelections = 'modifier_selections';
  static const colNote = 'note';
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

  Future<List<Map<String, Object?>>> getByOrderIds(
    List<String> orderIds,
  ) async {
    if (orderIds.isEmpty) {
      return const [];
    }

    final db = await AppDatabase.instance();

    final results = <Map<String, Object?>>[];
    const maxArgs = 999;
    for (var start = 0; start < orderIds.length; start += maxArgs) {
      final chunk = orderIds.sublist(
        start,
        (start + maxArgs).clamp(0, orderIds.length),
      );
      final placeholders = List.filled(chunk.length, '?').join(', ');
      results.addAll(
        await db.query(
          tableName,
          where: '$colOrderId IN ($placeholders)',
          whereArgs: chunk,
        ),
      );
    }

    return results;
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

  Future<int> updateQuantity(
    String id, {
    required int quantity,
    Transaction? txn,
  }) async {
    final DatabaseExecutor db = txn ?? await AppDatabase.instance();
    return await db.update(
      tableName,
      {colQuantity: quantity},
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(String id, {Transaction? txn}) async {
    final DatabaseExecutor db = txn ?? await AppDatabase.instance();
    return await db.delete(tableName, where: '$colId = ?', whereArgs: [id]);
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
