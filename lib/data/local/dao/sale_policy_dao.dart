import 'package:sqflite/sqflite.dart';
import '../app_database.dart';

class SalePolicyDao {
  static const tableName = 'sale_policies';

  // Columns
  static const colId = 'id';
  static const colVatPercent = 'vat_percent';
  static const colUsdToKhrRate = 'usd_to_khr_rate';

  // We enforce a single row by always using ID = 1
  static const _singletonId = 1;

  Future<Map<String, Object?>?> get() async {
    final db = await AppDatabase.instance();
    final results = await db.query(
      tableName,
      where: '$colId = ?',
      whereArgs: [_singletonId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> insertOrUpdate(Map<String, Object?> data) async {
    final db = await AppDatabase.instance();
    
    // Force the ID to be the singleton ID so we overwrite the existing policy
    final row = Map<String, Object?>.from(data);
    row[colId] = _singletonId;

    return await db.insert(
      tableName,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}