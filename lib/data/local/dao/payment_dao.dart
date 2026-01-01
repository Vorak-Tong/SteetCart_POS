import 'package:sqflite/sqflite.dart';
import '../app_database.dart';

class PaymentDao {
  static const tableName = 'payments';

  // Columns
  static const colId = 'id';
  static const colOrderId = 'order_id'; // Foreign Key to orders
  static const colPaymentMethod = 'payment_method';
  static const colReceiveAmountKhr = 'receive_amount_khr';
  static const colReceiveAmountUsd = 'receive_amount_usd';
  static const colChangeKhr = 'change_khr';
  static const colChangeUsd = 'change_usd';

  // Get payment for a specific order
  Future<Map<String, Object?>?> getByOrderId(String orderId) async {
    final db = await AppDatabase.instance();
    final results = await db.query(
      tableName,
      where: '$colOrderId = ?',
      whereArgs: [orderId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Insert a payment
  Future<int> insert(Map<String, Object?> data, {Transaction? txn}) async {
    final DatabaseExecutor db = txn ?? await AppDatabase.instance();
    return await db.insert(
      tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Delete payment for an order
  Future<int> deleteByOrderId(String orderId, {Transaction? txn}) async {
    final DatabaseExecutor db = txn ?? await AppDatabase.instance();
    return await db.delete(
      tableName,
      where: '$colOrderId = ?',
      whereArgs: [orderId],
    );
  }
}