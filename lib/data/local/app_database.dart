import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static const _dbName = 'street_cart_pos_v3.db';
  static const _dbVersion = 3;

  static Database? _db;

  static String? _testPath;

  @visibleForTesting
  static void switchToInMemoryForTesting() {
    _testPath = inMemoryDatabasePath;
  }

  static Future<Database> instance() async {
    if (_db != null) {
      return _db!;
    }

    String dbPath = _testPath ?? '';
    if (dbPath.isEmpty) {
      final directory = await getApplicationSupportDirectory();
      dbPath = p.join(directory.path, _dbName);
    }
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
    // 1. Categories
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // 2. Products
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        base_price REAL NOT NULL,
        image TEXT,
        category_id TEXT,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
      )
    ''');

    // 3. Modifier Groups
    await db.execute('''
      CREATE TABLE modifier_groups (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        product_id TEXT,
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
      )
    ''');

    // 4. Modifier Options
    await db.execute('''
      CREATE TABLE modifier_options (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL,
        group_id TEXT NOT NULL,
        FOREIGN KEY (group_id) REFERENCES modifier_groups (id) ON DELETE CASCADE
      )
    ''');

    // 5. Orders
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        timestamp INTEGER NOT NULL,
        order_type INTEGER NOT NULL,
        payment_type INTEGER NOT NULL,
        status INTEGER NOT NULL
      )
    ''');

    // 6. Order Items
    await db.execute('''
      CREATE TABLE order_items (
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        product_id TEXT,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE SET NULL
      )
    ''');

    // 7. Payments
    await db.execute('''
      CREATE TABLE payments (
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        payment_method INTEGER NOT NULL,
        receive_amount_khr INTEGER NOT NULL,
        receive_amount_usd REAL NOT NULL,
        change_khr INTEGER NOT NULL,
        change_usd REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE
      )
    ''');

    // 8. Sale Policies
    await db.execute('''
      CREATE TABLE sale_policies (
        id INTEGER PRIMARY KEY,
        vat_percent INTEGER NOT NULL,
        usd_to_khr_rate INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE categories ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1');
    }
    if (oldVersion < 3) {
      // Recreate modifier_groups to allow nullable product_id for Global Modifiers
      // We drop both tables to ensure clean schema recreation
      await db.execute('DROP TABLE IF EXISTS modifier_options');
      await db.execute('DROP TABLE IF EXISTS modifier_groups');

      await db.execute('''
        CREATE TABLE modifier_groups (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          product_id TEXT,
          FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE modifier_options (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          price REAL,
          group_id TEXT NOT NULL,
          FOREIGN KEY (group_id) REFERENCES modifier_groups (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  static Future<void> reset() async {
    await close();
    // Only delete the file if we are NOT in memory
    if (_testPath == null) {
      final directory = await getApplicationSupportDirectory();
      final dbPath = p.join(directory.path, _dbName);
      await deleteDatabase(dbPath);
    }
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