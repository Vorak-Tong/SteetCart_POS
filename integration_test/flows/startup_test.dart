import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:street_cart_pos/data/local/app_database.dart';
import 'package:street_cart_pos/main.dart' as app;
import 'package:street_cart_pos/ui/menu/widgets/menu_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Initialize FFI for the test environment
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    // Reset the real database file on disk to start fresh
    await AppDatabase.reset();
  });

  testWidgets('App startup smoke test', (WidgetTester tester) async {
    // Launch the app
    await app.main();
    
    // Wait for the app to settle (animations, DB loading)
    await tester.pumpAndSettle();

    // Verify we are on the MenuPage
    expect(find.byType(MenuPage), findsOneWidget);
  });
}