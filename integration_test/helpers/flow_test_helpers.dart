import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:street_cart_pos/data/local/app_database.dart';
import 'package:street_cart_pos/ui/core/widgets/product_item_card.dart';
import 'package:street_cart_pos/ui/menu/utils/menu_tab_state.dart';
import 'package:street_cart_pos/ui/sale/utils/sale_tab_state.dart';

class FlowTestHelpers {
  static Future<void> configureSqfliteForPlatform() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  static Future<void> resetDb() => AppDatabase.reset();

  static void resetTabState() {
    saleTabIndex.value = 0;
    menuTabIndex.value = 0;
  }

  static Future<void> pumpApp(
    WidgetTester tester, {
    required Future<void> Function() mainEntrypoint,
  }) async {
    resetTabState();

    await mainEntrypoint();
    await tester.pump();

    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pumpAndSettle();
  }

  static Finder appBarTitle(String title) {
    return find.descendant(of: find.byType(AppBar), matching: find.text(title));
  }

  static Finder bottomNavItem(String label) {
    return find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.text(label),
    );
  }

  static Finder textFieldWithHint(String hintText) {
    return find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == hintText,
    );
  }

  static Finder anySegmentedButton() =>
      find.byWidgetPredicate((w) => w is SegmentedButton);

  static Finder segmentedButtonLabelText(String label) {
    return find.descendant(of: anySegmentedButton(), matching: find.text(label));
  }

  static Future<void> openDrawer(WidgetTester tester) async {
    final drawerButton = find.byTooltip('Open navigation menu');
    expect(drawerButton, findsOneWidget);
    await tester.tap(drawerButton);
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsOneWidget);
  }

  static Future<void> goDrawerItem(WidgetTester tester, String label) async {
    await openDrawer(tester);
    await tester.tap(
      find.descendant(of: find.byType(Drawer), matching: find.text(label)).first,
    );
    await tester.pumpAndSettle();
  }

  static Future<void> addProductToCart(
    WidgetTester tester, {
    required String productName,
    required int quantity,
    String? singleSelectOptionContains,
    List<String>? singleSelectOptionsContain,
  }) async {
    final card = find.ancestor(
      of: find.text(productName),
      matching: find.byType(ProductItemCard),
    );
    expect(card, findsOneWidget);
    await tester.ensureVisible(card);
    await tester.tap(card, warnIfMissed: false);
    await tester.pumpAndSettle();

    final requested = <String>[
      if (singleSelectOptionContains != null) singleSelectOptionContains,
      ...?singleSelectOptionsContain,
    ];

    for (final label in requested) {
      final option = find.textContaining(label);
      expect(option, findsAtLeastNWidgets(1));
      await tester.ensureVisible(option.first);
      await tester.tap(option.first, warnIfMissed: false);
      await tester.pumpAndSettle();
    }

    for (int i = 1; i < quantity; i++) {
      await tester.tap(find.byTooltip('Increase quantity'));
      await tester.pump();
    }

    await tester.tap(find.widgetWithText(FilledButton, 'Add to cart'));
    await tester.pumpAndSettle();
  }
}
