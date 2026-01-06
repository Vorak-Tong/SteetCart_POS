import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:street_cart_pos/data/repositories/order_history_repository.dart';
import 'package:street_cart_pos/data/repositories/sale_policy_repository.dart';
import 'package:street_cart_pos/data/repositories/store_profile_repository.dart';
import 'package:street_cart_pos/domain/models/enums.dart';
import 'package:street_cart_pos/domain/models/order.dart';
import 'package:street_cart_pos/domain/models/order_modifier_selection.dart';
import 'package:street_cart_pos/domain/models/order_product.dart';
import 'package:street_cart_pos/domain/models/product.dart';
import 'package:street_cart_pos/domain/models/sale_policy.dart';
import 'package:street_cart_pos/domain/models/store_profile.dart';
import 'package:street_cart_pos/ui/core/theme/app_theme.dart';
import 'package:street_cart_pos/ui/sale/viewmodel/order_viewmodel.dart';
import 'package:street_cart_pos/ui/sale/widgets/order_tab/order_page.dart';
import 'package:street_cart_pos/ui/sale/widgets/order_tab/order_status_edit_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  OrderViewModel buildViewModel() {
    final order = Order(
      id: 'order-1',
      timeStamp: DateTime(2026, 1, 1, 12, 0),
      orderType: OrderType.dineIn,
      paymentType: PaymentMethod.cash,
      cartStatus: CartStatus.finalized,
      orderStatus: OrderStatus.inPrep,
      vatPercentApplied: 10,
      usdToKhrRateApplied: 4000,
      roundingModeApplied: RoundingMode.roundUp,
      orderProducts: [
        OrderProduct(
          id: 'oi-1',
          quantity: 1,
          product: Product(id: 'p1', name: 'Iced Tea', basePrice: 1.5),
          modifierSelections: const [
            OrderModifierSelection(
              groupName: 'Sugar Level',
              optionNames: ['50%'],
            ),
          ],
          note: 'No straw',
        ),
      ],
    );

    return OrderViewModel(
      initialDate: DateTime(2026, 1, 1),
      orderHistoryRepository: _FakeOrderHistoryRepository([order]),
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

  Future<void> pumpOrderPage(
    WidgetTester tester,
    OrderViewModel viewModel,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: OrderPage(viewModel: viewModel)),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('OrderPage expands and shows order items', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    final viewModel = buildViewModel();
    addTearDown(viewModel.dispose);

    await pumpOrderPage(tester, viewModel);

    expect(find.text('Order 1'), findsOneWidget);
    expect(find.text('Iced Tea'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('order_toggle_order-1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Iced Tea'), findsOneWidget);
    expect(find.textContaining('Sugar Level:'), findsOneWidget);
    expect(find.textContaining('Note: No straw'), findsOneWidget);
  });

  testWidgets('OrderPage shows status edit sheet', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    final viewModel = buildViewModel();
    addTearDown(viewModel.dispose);

    await pumpOrderPage(tester, viewModel);

    await tester.tap(find.byKey(const ValueKey('order_edit_status_order-1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

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

class _FakeOrderHistoryRepository extends OrderHistoryRepository {
  _FakeOrderHistoryRepository(this._orders);

  final List<Order> _orders;

  @override
  Future<List<Order>> getOrders() async => _orders;

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;
    final current = _orders[index];
    current.updateOrderStatus(status);
  }
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
