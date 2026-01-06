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
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    await AppDatabase.reset();
    await seedMenuForSaleFlows();
  });

  testWidgets(
    'Flow 2: checkout and order status updates (inPrep → ready → served)',
    (WidgetTester tester) async {
      await FlowTestHelpers.pumpApp(tester, mainEntrypoint: app.main);

      // Ensure we are on Sale tab.
      await tester.tap(FlowTestHelpers.bottomNavItem('Sale').first);
      await tester.pumpAndSettle();

      // Add 2× Iced Matcha Latte with Medium size.
      await FlowTestHelpers.addProductToCart(
        tester,
        productName: 'Iced Matcha Latte',
        quantity: 2,
        singleSelectOptionContains: 'Medium',
      );

      // Add 3× Iced Latte (no modifiers).
      await FlowTestHelpers.addProductToCart(
        tester,
        productName: 'Iced Latte',
        quantity: 3,
      );

      // Go to Cart tab and pay in KHR (cash).
      await tester.tap(FlowTestHelpers.bottomNavItem('Cart').first);
      await tester.pumpAndSettle();

      expect(find.text('Cart Items'), findsOneWidget);
      expect(find.text('Iced Matcha Latte'), findsOneWidget);
      expect(find.text('Iced Latte'), findsOneWidget);

      // Ensure payment method is Cash (default), then enter enough KHR.
      expect(FlowTestHelpers.anySegmentedButton(), findsAtLeastNWidgets(1));
      await tester.tap(
        FlowTestHelpers.segmentedButtonLabelText('Cash').first,
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('cart_received_khr')),
        '1000000',
      );
      await tester.pumpAndSettle();

      // Checkout (should switch to Orders tab).
      await tester.tap(find.widgetWithText(FilledButton, 'Checkout'));
      await tester.pumpAndSettle();

      // Orders page content.
      expect(find.text('Showing orders on:'), findsOneWidget);

      // Default filter is "In prep"; update status to Ready.
      expect(find.byTooltip('Edit status'), findsOneWidget);
      await tester.tap(find.byTooltip('Edit status'));
      await tester.pumpAndSettle();
      expect(find.text('Update status'), findsOneWidget);
      await tester.tap(find.text('Ready').last);
      await tester.pumpAndSettle();

      // Switch filter to Ready, then update to Served.
      await tester.tap(
        FlowTestHelpers.segmentedButtonLabelText('Ready').first,
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip('Edit status'), findsOneWidget);
      await tester.tap(find.byTooltip('Edit status'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Served').last);
      await tester.pumpAndSettle();

      // Switch filter to Served and verify the order is present.
      await tester.tap(
        FlowTestHelpers.segmentedButtonLabelText('Served').first,
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip('Edit status'), findsOneWidget);
      expect(find.text('Served'), findsAtLeastNWidgets(1));
    },
  );
}
