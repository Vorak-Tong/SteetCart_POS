import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static const _dbName = 'street_cart_pos.db';
  static const _dbVersion = 1;

  static Database? _db;

  static Future<Database> instance() async {
    if (_db != null) {
      return _db!;
    }

    final directory = await getApplicationSupportDirectory();
    final dbPath = p.join(directory.path, _dbName);
    _db = await openDatabase(
      dbPath,
      version: _dbVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return _db!;
  }

  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future<void> _onCreate(Database db, int version) async {
    // TODO: Add CREATE TABLE statements.
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // TODO: Handle schema migrations.
  }

  static Future<void> reset() async {
    await close();
    final directory = await getApplicationSupportDirectory();
    final dbPath = p.join(directory.path, _dbName);
    await deleteDatabase(dbPath);
  }

  static Future<void> close() async {
    final db = _db;
    if (db == null) {
      return;
    }

    await db.close();
    _db = null;
  }
}