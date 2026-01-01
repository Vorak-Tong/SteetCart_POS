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
    // 1. Categories
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL
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
        product_id TEXT NOT NULL,
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