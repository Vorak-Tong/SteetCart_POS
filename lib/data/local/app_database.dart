import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static const _dbName = 'street_cart_pos_v3.db';
  static const _dbVersion = 7;

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
        description TEXT,
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
        name TEXT NOT NULL
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
        product_name TEXT,
        unit_price REAL,
        product_image TEXT,
        product_description TEXT,
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
      await db.execute(
        'ALTER TABLE categories ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1',
      );
    }
    if (oldVersion < 4) {
      await db.transaction((txn) async {
        final tables = await txn.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table'",
        );
        final tableNames = tables
            .map((row) => row['name'])
            .whereType<String>()
            .toSet();

        final hasGroups = tableNames.contains('modifier_groups');
        final hasOptions = tableNames.contains('modifier_options');

        if (!hasGroups || !hasOptions) {
          await txn.execute('''
            CREATE TABLE IF NOT EXISTS modifier_groups (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL
            )
          ''');
          await txn.execute('''
            CREATE TABLE IF NOT EXISTS modifier_options (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              price REAL,
              group_id TEXT NOT NULL,
              FOREIGN KEY (group_id) REFERENCES modifier_groups (id) ON DELETE CASCADE
            )
          ''');
          await txn.execute('''
            CREATE TABLE IF NOT EXISTS product_modifier_groups (
              product_id TEXT NOT NULL,
              group_id TEXT NOT NULL,
              PRIMARY KEY (product_id, group_id),
              FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
              FOREIGN KEY (group_id) REFERENCES modifier_groups (id) ON DELETE CASCADE
            )
          ''');
          return;
        }

        await txn.execute(
          'ALTER TABLE modifier_options RENAME TO modifier_options_old',
        );
        await txn.execute(
          'ALTER TABLE modifier_groups RENAME TO modifier_groups_old',
        );

        await txn.execute('''
          CREATE TABLE modifier_groups (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL
          )
        ''');

        await txn.execute('''
          CREATE TABLE modifier_options (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            price REAL,
            group_id TEXT NOT NULL,
            FOREIGN KEY (group_id) REFERENCES modifier_groups (id) ON DELETE CASCADE
          )
        ''');

        await txn.execute('''
          CREATE TABLE product_modifier_groups (
            product_id TEXT NOT NULL,
            group_id TEXT NOT NULL,
            PRIMARY KEY (product_id, group_id),
            FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
            FOREIGN KEY (group_id) REFERENCES modifier_groups (id) ON DELETE CASCADE
          )
        ''');

        String normalizeName(Object? value) =>
            (value as String? ?? '').trim().toLowerCase();

        Future<void> copyOptions({
          required String fromGroupId,
          required String toGroupId,
        }) async {
          final optRows = await txn.query(
            'modifier_options_old',
            where: 'group_id = ?',
            whereArgs: [fromGroupId],
          );
          for (final opt in optRows) {
            await txn.insert('modifier_options', {
              'id': opt['id'],
              'name': opt['name'],
              'price': opt['price'],
              'group_id': toGroupId,
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }

        Future<int> countOptions(String groupId) async {
          final rows = await txn.rawQuery(
            'SELECT COUNT(*) as cnt FROM modifier_options WHERE group_id = ?',
            [groupId],
          );
          if (rows.isEmpty) return 0;
          final value = rows.first['cnt'];
          return (value as int?) ?? 0;
        }

        final canonicalByName = <String, String>{};

        // 1) Migrate existing global modifier groups first (product_id IS NULL)
        final globalGroups = await txn.query(
          'modifier_groups_old',
          where: 'product_id IS NULL',
          orderBy: 'name COLLATE NOCASE ASC, id ASC',
        );

        for (final row in globalGroups) {
          final id = row['id'] as String?;
          final name = row['name'] as String?;
          if (id == null || name == null) continue;

          await txn.insert('modifier_groups', {
            'id': id,
            'name': name,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
          canonicalByName.putIfAbsent(normalizeName(name), () => id);
          await copyOptions(fromGroupId: id, toGroupId: id);
        }

        // 2) Migrate per-product groups -> join table, reusing/creating canonical globals by name.
        final productGroups = await txn.query(
          'modifier_groups_old',
          where: 'product_id IS NOT NULL',
          orderBy: 'product_id ASC, name COLLATE NOCASE ASC, id ASC',
        );

        for (final row in productGroups) {
          final productId = row['product_id'] as String?;
          final sourceGroupId = row['id'] as String?;
          final name = row['name'] as String?;
          if (productId == null || sourceGroupId == null || name == null) {
            continue;
          }

          final normalized = normalizeName(name);
          var canonicalGroupId = canonicalByName[normalized];

          if (canonicalGroupId == null) {
            // Reuse the product-scoped group id as the canonical global id.
            canonicalGroupId = sourceGroupId;
            canonicalByName[normalized] = canonicalGroupId;

            await txn.insert('modifier_groups', {
              'id': canonicalGroupId,
              'name': name,
            }, conflictAlgorithm: ConflictAlgorithm.ignore);

            await copyOptions(
              fromGroupId: sourceGroupId,
              toGroupId: canonicalGroupId,
            );
          } else {
            // If the canonical group has no options (but the product group does), copy them.
            final existingCount = await countOptions(canonicalGroupId);
            if (existingCount == 0) {
              await copyOptions(
                fromGroupId: sourceGroupId,
                toGroupId: canonicalGroupId,
              );
            }
          }

          await txn.insert('product_modifier_groups', {
            'product_id': productId,
            'group_id': canonicalGroupId,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }

        await txn.execute('DROP TABLE IF EXISTS modifier_options_old');
        await txn.execute('DROP TABLE IF EXISTS modifier_groups_old');
      });
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE products ADD COLUMN description TEXT');
    }
    if (oldVersion < 6) {
      await db.execute(
        'ALTER TABLE products ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1',
      );
    }
    if (oldVersion < 7) {
      await db.execute('ALTER TABLE order_items ADD COLUMN product_name TEXT');
      await db.execute('ALTER TABLE order_items ADD COLUMN unit_price REAL');
      await db.execute('ALTER TABLE order_items ADD COLUMN product_image TEXT');
      await db.execute(
        'ALTER TABLE order_items ADD COLUMN product_description TEXT',
      );

      // Backfill snapshots for existing rows where possible.
      await db.execute('''
        UPDATE order_items
        SET product_name = (
          SELECT name FROM products WHERE products.id = order_items.product_id
        )
        WHERE product_name IS NULL AND product_id IS NOT NULL
      ''');

      await db.execute('''
        UPDATE order_items
        SET unit_price = (
          SELECT base_price FROM products WHERE products.id = order_items.product_id
        )
        WHERE unit_price IS NULL AND product_id IS NOT NULL
      ''');

      await db.execute('''
        UPDATE order_items
        SET product_image = (
          SELECT image FROM products WHERE products.id = order_items.product_id
        )
        WHERE product_image IS NULL AND product_id IS NOT NULL
      ''');

      await db.execute('''
        UPDATE order_items
        SET product_description = (
          SELECT description FROM products WHERE products.id = order_items.product_id
        )
        WHERE product_description IS NULL AND product_id IS NOT NULL
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
