import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:street_cart_pos/data/local/app_database.dart';
import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/main.dart' as app;
import 'package:street_cart_pos/ui/menu/widgets/menu_tab/menu_item_card.dart';
import '../helpers/flow_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    await AppDatabase.reset();
  });

  testWidgets(
    'Flow 1: first boot menu setup (categories, modifiers, products)',
    (WidgetTester tester) async {
      await FlowTestHelpers.pumpApp(tester, mainEntrypoint: app.main);

      // Go to Menu feature.
      await FlowTestHelpers.goDrawerItem(tester, 'Menu');
      expect(FlowTestHelpers.appBarTitle('Menu Management'), findsOneWidget);

      // --- Categories: Tea + Coffee ---
      await tester.tap(FlowTestHelpers.bottomNavItem('Category').first);
      await tester.pumpAndSettle();
      expect(FlowTestHelpers.appBarTitle('Category'), findsOneWidget);

      Future<void> createCategory(String name) async {
        await tester.tap(find.widgetWithText(FilledButton, 'Add New'));
        await tester.pumpAndSettle();
        expect(find.text('Create Category'), findsOneWidget);

        await tester.enterText(
          FlowTestHelpers.textFieldWithHint('e.g., Coffee'),
          name,
        );
        await tester.pump();
        await tester.tap(find.widgetWithText(FilledButton, 'Save'));
        await tester.pumpAndSettle();

        expect(find.text(name), findsAtLeastNWidgets(1));
      }

      await createCategory('Tea');
      await createCategory('Coffee');

      // --- Modifiers: Sugar + Size ---
      await tester.tap(FlowTestHelpers.bottomNavItem('Modifier').first);
      await tester.pumpAndSettle();
      expect(FlowTestHelpers.appBarTitle('Modifier'), findsOneWidget);

      Future<void> createModifierGroup({
        required String groupName,
        required String priceBehaviorLabel,
        required List<String> optionLabels,
        List<String>? optionPrices,
      }) async {
        await tester.tap(find.widgetWithText(FilledButton, 'Add New'));
        await tester.pumpAndSettle();
        expect(find.text('Add Modifier Group'), findsOneWidget);

        await tester.enterText(
          FlowTestHelpers.textFieldWithHint('e.g. Size'),
          groupName,
        );
        await tester.pump();

        // Set price behavior.
        await tester.tap(find.byType(DropdownButtonFormField<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text(priceBehaviorLabel).last);
        await tester.pumpAndSettle();

        // Ensure we have enough option rows.
        final addOptionButton = find.text('+ Add Another Option');
        for (int i = 0; i < optionLabels.length - 1; i++) {
          await tester.tap(addOptionButton);
          await tester.pump();
        }

        final optionLabelFields = find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.hintText == 'Option Label',
        );
        expect(optionLabelFields, findsNWidgets(optionLabels.length));

        for (int i = 0; i < optionLabels.length; i++) {
          await tester.enterText(optionLabelFields.at(i), optionLabels[i]);
        }
        await tester.pump();

        if (optionPrices != null) {
          final priceFields = find.byWidgetPredicate(
            (w) => w is TextField && w.decoration?.hintText == '+ \$ 0.00',
          );
          expect(priceFields, findsNWidgets(optionPrices.length));
          for (int i = 0; i < optionPrices.length; i++) {
            await tester.enterText(priceFields.at(i), optionPrices[i]);
          }
          await tester.pump();
        }

        await tester.ensureVisible(find.widgetWithText(FilledButton, 'Create'));
        await tester.tap(find.widgetWithText(FilledButton, 'Create'));
        await tester.pumpAndSettle();

        expect(find.text(groupName), findsAtLeastNWidgets(1));
      }

      await createModifierGroup(
        groupName: 'Sugar',
        priceBehaviorLabel: 'No Price Change',
        optionLabels: const ['No sugar', 'Less sugar', 'Normal sugar', 'More sugar'],
      );

      await createModifierGroup(
        groupName: 'Size',
        priceBehaviorLabel: 'Price Change',
        optionLabels: const ['Small', 'Medium', 'Large'],
        optionPrices: const ['0', '0.5', '0.75'],
      );

      // --- Products: Iced Latte + Iced Matcha Latte ---
      await tester.tap(FlowTestHelpers.bottomNavItem('Menu').first);
      await tester.pumpAndSettle();
      expect(FlowTestHelpers.appBarTitle('Menu Management'), findsOneWidget);

      Future<void> createProduct({
        required String name,
        required String basePrice,
        required String categoryName,
        required List<String> modifierGroups,
      }) async {
        await tester.tap(find.widgetWithText(FilledButton, 'Add New'));
        await tester.pumpAndSettle();
        expect(find.text('Add New Product'), findsOneWidget);

        await tester.enterText(
          FlowTestHelpers.textFieldWithHint('e.g., Ice Latte'),
          name,
        );
        await tester.enterText(
          FlowTestHelpers.textFieldWithHint('\$ 0.00'),
          basePrice,
        );
        await tester.pump();

        // Category dropdown
        await tester.ensureVisible(find.text('Category (Optional)'));
        await tester.tap(find.text('Uncategorized').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text(categoryName).last);
        await tester.pumpAndSettle();

        // Modifier groups
        for (final group in modifierGroups) {
          await tester.ensureVisible(find.text('Modifier Groups'));
          await tester.tap(find.text('+ Add Another Option').first);
          await tester.pumpAndSettle();
          expect(find.text('Select Modifier Group'), findsOneWidget);
          await tester.tap(find.text(group).last);
          await tester.pumpAndSettle();
        }

        await tester.ensureVisible(find.widgetWithText(FilledButton, 'Create Product'));
        await tester.tap(find.widgetWithText(FilledButton, 'Create Product'));
        await tester.pumpAndSettle();

        expect(find.text(name), findsAtLeastNWidgets(1));
      }

      await createProduct(
        name: 'Iced Latte',
        basePrice: '2.0',
        categoryName: 'Coffee',
        modifierGroups: const [],
      );

      await createProduct(
        name: 'Iced Matcha Latte',
        basePrice: '2.5',
        categoryName: 'Tea',
        modifierGroups: const ['Sugar', 'Size'],
      );

      // Verify menu card details show expected modifier text.
      expect(find.text('Iced Latte'), findsOneWidget);
      expect(find.text('No Modifiers'), findsAtLeastNWidgets(1));

      expect(find.text('Iced Matcha Latte'), findsOneWidget);
      await tester.ensureVisible(find.text('Iced Matcha Latte'));
      final icedMatchaCard = find.ancestor(
        of: find.text('Iced Matcha Latte'),
        matching: find.byType(MenuItemCard),
      );
      expect(icedMatchaCard, findsOneWidget);
      expect(
        find.descendant(of: icedMatchaCard, matching: find.textContaining('Sugar')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: icedMatchaCard, matching: find.textContaining('Size')),
        findsOneWidget,
      );

      // Verify persistence via repository reload.
      await MenuRepository().init();
      await tester.pumpAndSettle();
      expect(find.text('Iced Latte'), findsOneWidget);
      expect(find.text('Iced Matcha Latte'), findsOneWidget);
    },
  );
}
