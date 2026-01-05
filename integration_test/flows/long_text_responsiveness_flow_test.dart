import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:street_cart_pos/data/local/app_database.dart';
import 'package:street_cart_pos/main.dart' as app;
import 'package:street_cart_pos/ui/report/widgets/report_page.dart';
import 'package:street_cart_pos/ui/report/widgets/report_kpi_section.dart';
import 'package:street_cart_pos/ui/sale/widgets/cart_tab/cart_page.dart';

import '../helpers/flow_test_helpers.dart';
import '../helpers/seed_long_text_menu.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    await AppDatabase.reset();
    await seedLongTextMenu();
  });

  testWidgets('Long text: Sale→Cart→Orders→Report should not overflow', (
    WidgetTester tester,
  ) async {
    await FlowTestHelpers.pumpApp(tester, mainEntrypoint: app.main);

    // Ensure the long product is visible in Sale.
    await tester.tap(FlowTestHelpers.bottomNavItem('Sale').first);
    await tester.pumpAndSettle();

    final longProductFinder = find.textContaining('Iced Matcha Latte');
    expect(longProductFinder, findsAtLeastNWidgets(1));

    // Open selection sheet and pick long options.
    await FlowTestHelpers.addProductToCart(
      tester,
      productName: 'Iced Matcha Latte',
      quantity: 2,
      singleSelectOptionsContain: ['Less sugar', 'Medium (16oz)'],
    );

    // Cart should render long product name without throwing overflow errors.
    await tester.tap(FlowTestHelpers.bottomNavItem('Cart').first);
    await tester.pumpAndSettle();

    expect(find.text('Cart Items'), findsOneWidget);
    expect(longProductFinder, findsAtLeastNWidgets(1));

    // Checkout so the order can show up in Orders and Report.
    final receivedKhrField = find.byKey(const ValueKey('cart_received_khr'));
    final cartScrollable = find
        .descendant(
          of: find.byType(CartPage),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      receivedKhrField,
      200,
      scrollable: cartScrollable,
    );
    await tester.enterText(receivedKhrField, '1000000');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Checkout'));
    await tester.pumpAndSettle();

    // Ensure we are on Orders tab (checkout should switch, but make it explicit).
    await tester.tap(FlowTestHelpers.bottomNavItem('Order').first);
    await tester.pumpAndSettle();
    expect(find.text('Showing orders on:'), findsOneWidget);

    // Mark order served (inPrep -> ready -> served) so it appears in report.
    await tester.tap(find.byTooltip('Edit status'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ready').last);
    await tester.pumpAndSettle();

    await tester.tap(
      FlowTestHelpers.segmentedButtonLabelText('Ready').first,
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit status'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Served').last);
    await tester.pumpAndSettle();

    // Report page should render long labels too.
    await FlowTestHelpers.goDrawerItem(tester, 'Report');
    await tester.pumpAndSettle();

    expect(find.byKey(ReportKpiSection.totalOrdersKey), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(ReportKpiSection.totalOrdersKey)).data,
      '1',
    );
    final reportScrollable = find
        .descendant(
          of: find.byType(ReportPage),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      longProductFinder,
      250,
      scrollable: reportScrollable,
    );
    expect(longProductFinder, findsAtLeastNWidgets(1));
  });
}
