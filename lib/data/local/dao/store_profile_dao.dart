import 'package:sqflite/sqflite.dart';
import '../app_database.dart';

class StoreProfileDao {
  static const tableName = 'store_profiles';

  static const colId = 'id';
  static const colName = 'name';
  static const colPhone = 'phone';
  static const colAddress = 'address';

  static const _singletonId = 1;

  Future<Map<String, Object?>?> get() async {
    final db = await AppDatabase.instance();
    final results = await db.query(
      tableName,
      where: '$colId = ?',
      whereArgs: [_singletonId],
      limit: 1,
    );
    return results.isEmpty ? null : results.first;
  }

  Future<int> insertOrUpdate(Map<String, Object?> data) async {
    final db = await AppDatabase.instance();

    final row = Map<String, Object?>.from(data);
    row[colId] = _singletonId;

    return await db.insert(
      tableName,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
