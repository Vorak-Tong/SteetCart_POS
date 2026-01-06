import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/ui/menu/widgets/modifier_tab/modifier_page.dart';
import 'package:street_cart_pos/domain/models/modifier_group.dart';
import 'package:street_cart_pos/ui/menu/widgets/modifier_tab/modifier_item_card.dart';
import '../../helpers/fake_menu_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  setUp(() async {
    MenuRepository.setInstance(FakeMenuRepository());
    // Seed Data
    await MenuRepository().addModifierGroup(
      ModifierGroup(id: const Uuid().v4(), name: 'Ice Level'),
    );
  });

  testWidgets('ModifierPage add and edit flow', (WidgetTester tester) async {
    // Increase screen size to avoid overflow and scrolling issues
    tester.view.physicalSize = const Size(600, 1200);
    tester.view.devicePixelRatio = 1.0;
    // Set text scale factor to avoid overflow in dropdowns on small test screens
    tester.platformDispatcher.textScaleFactorTestValue = 0.5;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    // 1. Pump ModifierPage
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ModifierPage())),
    );
    await tester.pumpAndSettle();

    // Verify initial mock data exists
    expect(find.text('Ice Level'), findsOneWidget);

    // 2. Add New Modifier Group
    await tester.tap(find.text('Add New'));
    await tester.pumpAndSettle();

    // Verify navigation to form
    expect(find.text('Add Modifier Group'), findsOneWidget);

    // Enter Group Name (First TextField)
    await tester.enterText(find.byType(TextField).first, 'Extra Toppings');
    // Enter at least 1 option label (Option Label field)
    await tester.enterText(find.byType(TextField).at(1), 'Cheese');

    // Tap Create
    final createButton = find.widgetWithText(FilledButton, 'Create');
    await tester.scrollUntilVisible(
      createButton,
      500.0,
      scrollable: find
          .descendant(
            of: find.byType(SingleChildScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    // Verify new item is in the list
    expect(find.text('Extra Toppings'), findsOneWidget);

    // 3. Edit the new Modifier Group
    final newGroupCard = find.ancestor(
      of: find.text('Extra Toppings'),
      matching: find.byType(ModifierItemCard),
    );
    final editButton = find.descendant(
      of: newGroupCard,
      matching: find.byIcon(Icons.edit_outlined),
    );

    await tester.tap(editButton);
    await tester.pumpAndSettle();

    // Verify navigation to edit form
    expect(find.text('Edit Modifier Group'), findsOneWidget);
    expect(find.text('Extra Toppings'), findsOneWidget);

    // Change Group Name
    await tester.enterText(find.byType(TextField).first, 'Super Toppings');

    // Tap Save
    final saveButton = find.widgetWithText(FilledButton, 'Save');
    await tester.scrollUntilVisible(
      saveButton,
      500.0,
      scrollable: find
          .descendant(
            of: find.byType(SingleChildScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify item is updated in the list
    expect(find.text('Super Toppings'), findsOneWidget);
    expect(find.text('Extra Toppings'), findsNothing);
  });
}
