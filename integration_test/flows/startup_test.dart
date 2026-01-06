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
    // Initialize FFI for the test environment
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    // Reset the real database file on disk to start fresh
    await AppDatabase.reset();

    // Seed a minimal menu so startup assertions match the current app iteration.
    await seedMenuForSaleFlows();
  });

  testWidgets('Smoke: app boots and renders Sale', (WidgetTester tester) async {
    await FlowTestHelpers.pumpApp(tester, mainEntrypoint: app.main);

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Search products'), findsOneWidget);

    // Seeded product should appear in the Sale grid.
    expect(find.text('Iced Latte'), findsAtLeastNWidgets(1));

    // Shell bottom nav exists.
    expect(find.text('Sale'), findsAtLeastNWidgets(1));
    expect(find.text('Cart'), findsAtLeastNWidgets(1));
    expect(find.text('Order'), findsAtLeastNWidgets(1));
  });
}
