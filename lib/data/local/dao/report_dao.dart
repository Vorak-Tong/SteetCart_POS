import 'package:sqflite/sqflite.dart';
import '../app_database.dart';

class ReportDao {
  // This DAO handles data aggregation for reports.
  // It primarily reads from 'orders' to calculate totals.

  // Fetch all raw order rows within a date range
  Future<List<Map<String, Object?>>> getOrdersInRange(
    int startEpoch,
    int endEpoch,
  ) async {
    final db = await AppDatabase.instance();
    return await db.query(
      'orders',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [startEpoch, endEpoch],
      orderBy: 'timestamp DESC',
    );
  }

  // Example: Get total count of orders in a range (faster than loading all rows)
  Future<int> getOrderCountInRange(int startEpoch, int endEpoch) async {
    final db = await AppDatabase.instance();
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM orders WHERE timestamp BETWEEN ? AND ?',
      [startEpoch, endEpoch],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
