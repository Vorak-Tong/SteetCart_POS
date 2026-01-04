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
    
    // Trigger an initial pump to ensure the widget tree is built
    await tester.pump();
    
    // Robust wait for initial navigation (GoRouter async redirects, etc.)
    // We pump multiple times with duration to let async tasks complete
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    await tester.pumpAndSettle();

    // Verify the app root is present
    expect(find.byType(MaterialApp), findsOneWidget);

    // Verify the POS screen is loaded by checking for key UI elements.
    // The logs confirmed "Search products" and "Cart" are visible.
    expect(find.text('Search products'), findsOneWidget);
    expect(find.text('Cart'), findsOneWidget);
    
    // Verify database data is loaded (e.g. "Chicken Over Rice" from logs)
    // This confirms the full stack (UI + DB) is working.
    expect(find.text('Chicken Over Rice'), findsOneWidget);
  });
}