import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:street_cart_pos/ui/core/theme/app_theme.dart';
import 'package:street_cart_pos/ui/sale/widgets/cart_tab/cart_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CartPage renders order type and cart items', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: CartPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Order Type'), findsOneWidget);
    expect(find.text('Cart Items'), findsOneWidget);
    expect(find.text('Iced Tea'), findsOneWidget);
    expect(find.text('Fries'), findsOneWidget);
    expect(find.text('Chicken Over Rice'), findsOneWidget);
    expect(find.text('Subtotal'), findsOneWidget);
    expect(find.text('VAT (10%)'), findsOneWidget);
    expect(find.text('Payment Method'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('KHQR'), findsOneWidget);
    expect(find.byKey(const ValueKey('cart_received_usd')), findsOneWidget);
    expect(find.byKey(const ValueKey('cart_received_khr')), findsOneWidget);
    expect(find.text('Change'), findsOneWidget);
    expect(find.text('Grand total'), findsOneWidget);
    expect(find.text('Checkout'), findsOneWidget);
    expect(find.byTooltip('Clear cart'), findsOneWidget);

    final checkoutButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Checkout'),
    );
    expect(checkoutButton.onPressed, isNull);
  });

  testWidgets('Entering USD disables KHR field', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: CartPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Payment Method'),
      200,
      scrollable: find.ancestor(
        of: find.text('Iced Tea'),
        matching: find.byType(Scrollable),
      ),
    );

    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('cart_received_khr')))
          .enabled,
      isTrue,
    );

    await tester.enterText(
      find.byKey(const ValueKey('cart_received_usd')),
      '5',
    );
    await tester.pump();

    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('cart_received_khr')))
          .enabled,
      isFalse,
    );
  });

  testWidgets('Checkout enables when payment is sufficient', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: CartPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('cart_received_usd')),
      '50',
    );
    await tester.pump();

    final checkoutButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Checkout'),
    );
    expect(checkoutButton.onPressed, isNotNull);
  });

  testWidgets('Clear cart shows confirmation dialog', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: CartPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Clear cart'));
    await tester.pumpAndSettle();

    expect(find.text('Cancel cart?'), findsOneWidget);
    expect(find.text('This will clear all items in the cart.'), findsOneWidget);
    expect(find.text('Keep'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
  });
}
