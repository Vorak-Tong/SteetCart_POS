import 'package:sqflite/sqflite.dart';
import '../app_database.dart';

class PrinterSettingsDao {
  static const tableName = 'printer_settings';

  static const colId = 'id';
  static const colDeviceName = 'device_name';
  static const colBluetoothMac = 'bluetooth_mac';
  static const colPaperWidthMm = 'paper_width_mm';
  static const colDotsPerLine = 'dots_per_line';
  static const colCharsPerLine = 'chars_per_line';

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
