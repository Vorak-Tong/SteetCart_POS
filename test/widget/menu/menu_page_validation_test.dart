import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import 'package:street_cart_pos/ui/menu/widgets/menu_page.dart';

void main() {
  testWidgets('MenuPage shows error when adding item with empty categories', (WidgetTester tester) async {
    // 1. Pump MenuPage with empty categories
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: MenuPage(
          initialCategories: <Category>[],
          initialProducts: <Product>[],
        ),
      ),
    ));

    // 2. Tap "Add New" button
    await tester.tap(find.text('Add New'));
    await tester.pump(); // Process tap
    await tester.pump(const Duration(milliseconds: 100)); // Process SnackBar animation

    // 3. Verify SnackBar
    expect(find.text('Please create a Category first.'), findsOneWidget);
  });

  testWidgets('MenuPage navigates to form when categories exist', (WidgetTester tester) async {
    // 1. Pump MenuPage with default mock data (which has categories)
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: MenuPage()),
    ));

    // 2. Tap "Add New" button
    await tester.tap(find.text('Add New'));
    await tester.pumpAndSettle(); // Wait for navigation animation

    // 3. Verify navigation to ProductFormPage (Title is 'Add New Item')
    expect(find.text('Add New Item'), findsOneWidget);
    expect(find.text('Please create a Category first.'), findsNothing);
  });
}