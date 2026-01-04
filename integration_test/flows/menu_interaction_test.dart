import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:street_cart_pos/data/local/app_database.dart';
import 'package:street_cart_pos/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Initialize FFI for the test environment (Windows/Linux)
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    // Reset the database to ensure a clean state for this test
    await AppDatabase.reset();
  });

  testWidgets('Menu interaction flow (Filter & View Details)', (WidgetTester tester) async {
    // 1. Launch the app
    await app.main();
    await tester.pump();
    
    // Wait for the app to settle (handling async navigation/loading)
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      // Optimization: Stop waiting if the UI is already loaded
      if (find.text('Beverages').evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pumpAndSettle();

    // 2. Verify initial state: "Beverages" category should be visible
    expect(find.text('Beverages'), findsAtLeastNWidgets(1));

    // 3. Interact: Tap "Beverages" to filter the menu
    await tester.tap(find.text('Beverages').first);
    await tester.pumpAndSettle();

    // 4. Verify: "Soda Can" (a beverage) should be visible
    expect(find.text('Soda Can'), findsOneWidget);

    // 5. Interact: Tap "Soda Can" to open product details
    await tester.tap(find.text('Soda Can'));
    await tester.pumpAndSettle();

    // 6. Verify: We are on the detail page
    // The product name should be visible on the detail screen
    expect(find.text('Soda Can'), findsOneWidget);

    // 7. Interact: Go back to Menu
    // Check for standard BackButton or common back icons
    if (find.byType(BackButton).evaluate().isNotEmpty) {
      await tester.tap(find.byType(BackButton));
    } else if (find.byIcon(Icons.arrow_back).evaluate().isNotEmpty) {
      await tester.tap(find.byIcon(Icons.arrow_back));
    } else {
      // If no UI back button is found, simulate a system back press
      await tester.binding.handlePopRoute();
      await tester.pump(); // Allow navigation to start
    }
    await tester.pumpAndSettle();

    // 8. Interact: Tap "All" to clear filter
    await tester.tap(find.text('All').first);
    await tester.pumpAndSettle();

    // 9. Verify: "Chicken Over Rice" (Entree) should be visible again
    expect(find.text('Chicken Over Rice'), findsOneWidget);
  });
}