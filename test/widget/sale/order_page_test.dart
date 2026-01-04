import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:street_cart_pos/ui/core/theme/app_theme.dart';
import 'package:street_cart_pos/ui/sale/widgets/order_tab/order_page.dart';
import 'package:street_cart_pos/ui/sale/widgets/order_tab/order_status_edit_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('OrderPage expands and shows order items', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: OrderPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Order 1001'), findsOneWidget);
    expect(find.text('Iced Tea'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('order_toggle_order-1001')));
    await tester.pumpAndSettle();

    expect(find.text('Iced Tea'), findsWidgets);
    expect(find.textContaining('Sugar Level:'), findsOneWidget);
    expect(find.textContaining('Note: No straw'), findsOneWidget);
  });

  testWidgets('OrderPage shows status edit sheet', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: OrderPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('order_edit_status_order-1001')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Update status'), findsOneWidget);
    final sheet = find.byType(OrderStatusEditSheet);
    expect(sheet, findsOneWidget);
    expect(
      find.descendant(of: sheet, matching: find.text('Ready')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sheet, matching: find.text('Served')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sheet, matching: find.text('Cancelled')),
      findsOneWidget,
    );
  });
}
