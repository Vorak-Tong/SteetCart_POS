import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:street_cart_pos/data/repositories/cart_repository.dart';
import 'package:street_cart_pos/data/repositories/sale_policy_repository.dart';
import 'package:street_cart_pos/data/repositories/store_profile_repository.dart';
import 'package:street_cart_pos/domain/models/enums.dart';
import 'package:street_cart_pos/domain/models/order.dart';
import 'package:street_cart_pos/domain/models/order_modifier_selection.dart';
import 'package:street_cart_pos/domain/models/order_product.dart';
import 'package:street_cart_pos/domain/models/payment.dart';
import 'package:street_cart_pos/domain/models/product.dart';
import 'package:street_cart_pos/domain/models/sale_policy.dart';
import 'package:street_cart_pos/domain/models/store_profile.dart';
import 'package:street_cart_pos/ui/core/theme/app_theme.dart';
import 'package:street_cart_pos/ui/sale/viewmodel/cart_viewmodel.dart';
import 'package:street_cart_pos/ui/sale/widgets/cart_tab/cart_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  CartViewModel buildViewModel() {
    final draft = Order(
      id: 'draft-order',
      timeStamp: DateTime(2026, 1, 1, 12),
      orderType: OrderType.dineIn,
      paymentType: PaymentMethod.cash,
      cartStatus: CartStatus.draft,
      orderStatus: null,
      orderProducts: [
        OrderProduct(
          id: 'item-iced-tea',
          quantity: 2,
          product: Product(id: 'p1', name: 'Iced Tea', basePrice: 1.5),
          modifierSelections: const [
            OrderModifierSelection(
              groupName: 'Sugar',
              optionNames: ['Less sweet'],
            ),
            OrderModifierSelection(groupName: 'Ice', optionNames: ['Less ice']),
          ],
        ),
        OrderProduct(
          id: 'item-fries',
          quantity: 1,
          product: Product(id: 'p2', name: 'Fries', basePrice: 2.0),
          modifierSelections: const [
            OrderModifierSelection(groupName: 'Size', optionNames: ['L']),
          ],
        ),
        OrderProduct(
          id: 'item-chicken',
          quantity: 1,
          product: Product(id: 'p3', name: 'Chicken Over Rice', basePrice: 3.5),
          modifierSelections: const [],
        ),
      ],
    );

    return CartViewModel(
      cartRepository: _FakeCartRepository(draft),
      salePolicyRepository: _FakeSalePolicyRepository(
        const SalePolicy(vat: 10, exchangeRate: 4000),
      ),
      storeProfileRepository: _FakeStoreProfileRepository(
        const StoreProfile(
          name: 'My Store',
          phone: '0123456789',
          address: 'st1, Mod District, Mod City',
        ),
      ),
    );
  }

  Future<void> pumpCartPage(
    WidgetTester tester,
    CartViewModel viewModel,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: CartPage(viewModel: viewModel)),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('CartPage renders order type and cart items', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    final viewModel = buildViewModel();
    addTearDown(viewModel.dispose);

    await pumpCartPage(tester, viewModel);

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
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    final viewModel = buildViewModel();
    addTearDown(viewModel.dispose);

    await pumpCartPage(tester, viewModel);

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
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    final viewModel = buildViewModel();
    addTearDown(viewModel.dispose);

    await pumpCartPage(tester, viewModel);

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
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    final viewModel = buildViewModel();
    addTearDown(viewModel.dispose);

    await pumpCartPage(tester, viewModel);

    await tester.tap(find.byTooltip('Clear cart'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Cancel cart?'), findsOneWidget);
    expect(find.text('This will clear all items in the cart.'), findsOneWidget);
    expect(find.text('Keep'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
  });
}

class _FakeCartRepository extends CartRepository {
  _FakeCartRepository(this._draft);

  Order? _draft;

  @override
  Future<Order?> getDraftOrder() async => _draft;

  @override
  Future<void> deleteDraftOrder() async {
    _draft = null;
  }

  @override
  Future<void> updateOrderItemQuantity(
    String orderItemId, {
    required int quantity,
  }) async {}

  @override
  Future<void> checkoutDraftOrder({
    required String orderId,
    required DateTime finalizedAt,
    required OrderType orderType,
    required PaymentMethod paymentType,
    required Payment payment,
    required int vatPercentApplied,
    required int usdToKhrRateApplied,
    required RoundingMode roundingModeApplied,
  }) async {}
}

class _FakeSalePolicyRepository implements SalePolicyRepository {
  _FakeSalePolicyRepository(this._policy);

  SalePolicy _policy;

  @override
  Future<SalePolicy> getSalePolicy() async => _policy;

  @override
  Future<void> updateSalePolicy(SalePolicy policy) async {
    _policy = policy;
  }
}

class _FakeStoreProfileRepository implements StoreProfileRepository {
  _FakeStoreProfileRepository(this._profile);

  StoreProfile _profile;

  @override
  Future<StoreProfile> getStoreProfile() async => _profile;

  @override
  Future<void> updateStoreProfile(StoreProfile profile) async {
    _profile = profile;
  }
}
