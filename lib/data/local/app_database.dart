import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static const _dbName = 'street_cart_pos_v3.db';
  static const _dbVersion = 18;

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
        name TEXT NOT NULL CHECK (length(name) <= 15),
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // 2. Products
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL CHECK (length(name) <= 20),
        description TEXT CHECK (description IS NULL OR length(description) <= 80),
        base_price REAL NOT NULL,
        image TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        category_id TEXT,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
      )
    ''');

    // 3. Modifier Groups
    await db.execute('''
      CREATE TABLE modifier_groups (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL CHECK (length(name) <= 20),
        selection_type INTEGER NOT NULL DEFAULT 0,
        price_behavior INTEGER NOT NULL DEFAULT 1,
        min_selection INTEGER NOT NULL DEFAULT 0,
        max_selection INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // 4. Modifier Options
    await db.execute('''
      CREATE TABLE modifier_options (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL CHECK (length(name) <= 20),
        price REAL,
        is_default INTEGER NOT NULL DEFAULT 0,
        group_id TEXT NOT NULL,
        FOREIGN KEY (group_id) REFERENCES modifier_groups (id) ON DELETE CASCADE
      )
    ''');

    // 4b. Product Modifier Groups (join table)
    await db.execute('''
      CREATE TABLE product_modifier_groups (
        product_id TEXT NOT NULL,
        group_id TEXT NOT NULL,
        PRIMARY KEY (product_id, group_id),
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
        FOREIGN KEY (group_id) REFERENCES modifier_groups (id) ON DELETE CASCADE
      )
    ''');

    // 5. Orders
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        timestamp INTEGER NOT NULL,
        order_type TEXT NOT NULL CHECK (
          order_type IN ('dineIn', 'takeAway', 'delivery')
        ),
        payment_type TEXT NOT NULL CHECK (
          payment_type IN ('cash', 'KHQR')
        ),
        cart_status TEXT NOT NULL DEFAULT 'draft' CHECK (
          cart_status IN ('draft', 'finalized')
        ),
        order_status TEXT CHECK (
          order_status IN ('inPrep', 'ready', 'served', 'cancel')
        ),
        vat_percent_applied INTEGER CHECK (
          vat_percent_applied IS NULL OR
          (vat_percent_applied >= 0 AND vat_percent_applied <= 100)
        ),
        usd_to_khr_rate_applied INTEGER CHECK (
          usd_to_khr_rate_applied IS NULL OR usd_to_khr_rate_applied > 0
        ),
        rounding_mode_applied TEXT CHECK (
          rounding_mode_applied IS NULL OR
          rounding_mode_applied IN ('roundUp','roundDown')
        )
      )
    ''');

    // 6. Order Items
    await db.execute('''
      CREATE TABLE order_items (
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        product_id TEXT,
        product_name TEXT,
        unit_price REAL,
        product_image TEXT,
        product_description TEXT,
        modifier_selections TEXT,
        note TEXT,
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
        usd_to_khr_rate INTEGER NOT NULL,
        rounding_mode TEXT NOT NULL DEFAULT 'roundUp'
          CHECK(rounding_mode IN ('roundUp','roundDown'))
      )
    ''');

    // 9. Printer Settings
    await db.execute('''
      CREATE TABLE printer_settings (
        id INTEGER PRIMARY KEY,
        device_name TEXT,
        bluetooth_mac TEXT,
        paper_width_mm INTEGER NOT NULL DEFAULT 58,
        dots_per_line INTEGER NOT NULL DEFAULT 384,
        chars_per_line INTEGER NOT NULL DEFAULT 32
      )
    ''');

    // 9. Store Profile
    await db.execute('''
      CREATE TABLE store_profiles (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL CHECK(length(name) <= 30),
        phone TEXT NOT NULL CHECK(length(phone) <= 20),
        address TEXT NOT NULL CHECK(length(address) <= 80)
      )
    ''');
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // During development we prefer a predictable workflow over preserving existing data:
    // any schema version bump does a full rebuild of the database.
    await db.transaction((txn) async {
      await txn.execute('PRAGMA foreign_keys = OFF');
      await txn.execute('DROP TABLE IF EXISTS store_profiles');
      await txn.execute('DROP TABLE IF EXISTS printer_settings');
      await txn.execute('DROP TABLE IF EXISTS sale_policies');
      await txn.execute('DROP TABLE IF EXISTS payments');
      await txn.execute('DROP TABLE IF EXISTS order_items');
      await txn.execute('DROP TABLE IF EXISTS orders');
      await txn.execute('DROP TABLE IF EXISTS product_modifier_groups');
      await txn.execute('DROP TABLE IF EXISTS modifier_options');
      await txn.execute('DROP TABLE IF EXISTS modifier_groups');
      await txn.execute('DROP TABLE IF EXISTS products');
      await txn.execute('DROP TABLE IF EXISTS categories');
      await txn.execute('PRAGMA foreign_keys = ON');
    });

    await _onCreate(db, newVersion);
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
