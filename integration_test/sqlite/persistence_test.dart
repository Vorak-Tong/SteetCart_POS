import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:street_cart_pos/data/local/app_database.dart';
import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    // Start with a fresh database
    await AppDatabase.reset();
    // Initialize the repository (opens DB connection)
    await MenuRepository().init();
  });

  testWidgets('Database persistence check', (WidgetTester tester) async {
    final repo = MenuRepository();
    final catId = const Uuid().v4();
    
    // 1. Add data via Repository
    await repo.addCategory(Category(id: catId, name: 'Persistent Category'));

    // 2. Verify it is in memory
    expect(repo.categories.any((c) => c.id == catId), isTrue);

    // 3. Simulate app reload
    // Calling init() forces the repository to re-fetch data from the SQLite database
    await repo.init();
    
    // 4. Verify data is still there after reload
    // If this passes, it means the data was successfully written to the .db file
    expect(repo.categories.any((c) => c.id == catId), isTrue);
  });
}