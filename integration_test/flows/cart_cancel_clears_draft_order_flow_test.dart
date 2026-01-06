import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:street_cart_pos/data/local/app_database.dart';
import 'package:street_cart_pos/data/repositories/cart_repository.dart';
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
    'Flow 3: invalid USD payment then cancel cart clears draft order',
    (WidgetTester tester) async {
      await FlowTestHelpers.pumpApp(tester, mainEntrypoint: app.main);

      // Ensure we are on Sale tab.
      await tester.tap(FlowTestHelpers.bottomNavItem('Sale').first);
      await tester.pumpAndSettle();

      // Add 2× Iced Matcha Latte, select Small size and No sugar.
      await FlowTestHelpers.addProductToCart(
        tester,
        productName: 'Iced Matcha Latte',
        quantity: 2,
        singleSelectOptionsContain: const ['Small', 'No sugar'],
      );

      // Go to Cart.
      await tester.tap(FlowTestHelpers.bottomNavItem('Cart').first);
      await tester.pumpAndSettle();

      expect(find.text('Cart Items'), findsOneWidget);
      expect(find.text('Iced Matcha Latte'), findsOneWidget);
      expect(find.text('Size: Small'), findsOneWidget);
      expect(find.text('Sugar: No sugar'), findsOneWidget);

      // Enter an insufficient USD amount (valid number but not enough).
      await tester.enterText(
        find.byKey(const ValueKey('cart_received_usd')),
        '1',
      );
      await tester.pumpAndSettle();

      final checkoutFinder = find.widgetWithText(FilledButton, 'Checkout');
      expect(checkoutFinder, findsOneWidget);
      final checkoutButton = tester.widget<FilledButton>(checkoutFinder);
      expect(
        checkoutButton.onPressed,
        isNull,
        reason: 'Checkout must be disabled when payment is insufficient.',
      );

      // Cancel the cart via clear-cart dialog.
      await tester.tap(find.byTooltip('Clear cart'));
      await tester.pumpAndSettle();
      expect(find.text('Cancel cart?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Clear'));
      await tester.pumpAndSettle();

      expect(find.text('Iced Matcha Latte'), findsNothing);

      // Ensure draft order is removed from DB.
      final draft = await CartRepository().getDraftOrder();
      expect(draft, isNull);
    },
  );
}
