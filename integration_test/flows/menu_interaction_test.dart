import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:street_cart_pos/data/local/app_database.dart';
import 'package:street_cart_pos/main.dart' as app;

import '../helpers/flow_test_helpers.dart';
import '../helpers/seed_menu_for_sale_flows.dart';

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

    // Seed a minimal menu so this test reflects the current app iteration.
    await seedMenuForSaleFlows();
  });

  testWidgets('Smoke: navigate Menu tabs and filters', (
    WidgetTester tester,
  ) async {
    await FlowTestHelpers.pumpApp(tester, mainEntrypoint: app.main);

    await FlowTestHelpers.goDrawerItem(tester, 'Menu');
    await tester.pumpAndSettle();

    // Menu bottom nav (menu tab set) should be present.
    expect(find.text('Menu'), findsAtLeastNWidgets(1));
    expect(find.text('Category'), findsAtLeastNWidgets(1));
    expect(find.text('Modifier'), findsAtLeastNWidgets(1));

    // Product list is seeded.
    expect(find.text('Iced Latte'), findsAtLeastNWidgets(1));
    expect(find.text('Iced Matcha Latte'), findsAtLeastNWidgets(1));

    // Filter by category chip.
    await tester.tap(find.text('Coffee').first);
    await tester.pumpAndSettle();
    expect(find.text('Iced Latte'), findsAtLeastNWidgets(1));
    expect(find.text('Iced Matcha Latte'), findsNothing);

    // Category tab shows categories.
    await tester.tap(FlowTestHelpers.bottomNavItem('Category').first);
    await tester.pumpAndSettle();
    expect(find.text('Tea'), findsAtLeastNWidgets(1));
    expect(find.text('Coffee'), findsAtLeastNWidgets(1));

    // Modifier tab shows global modifier groups.
    await tester.tap(FlowTestHelpers.bottomNavItem('Modifier').first);
    await tester.pumpAndSettle();
    expect(find.text('Sugar'), findsAtLeastNWidgets(1));
    expect(find.text('Size'), findsAtLeastNWidgets(1));
  });
}
