import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:street_cart_pos/data/local/app_database.dart';

/// Sets up the environment for database unit tests.
/// Initializes FFI, mocks path_provider, and resets the DB before each test.
void setupDatabaseTests() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
  // Use in-memory database to avoid file locking and speed up tests
  AppDatabase.switchToInMemoryForTesting();

  setUpAll(() {
    // Mock path_provider (even though we use in-memory, some code might still call it)
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return '.';
      },
    );
  });

  setUp(() async {
    // Resetting closes the DB. For in-memory, this effectively wipes data.
    await AppDatabase.reset();
  });

  tearDown(() async {
    await AppDatabase.close();
  });
}