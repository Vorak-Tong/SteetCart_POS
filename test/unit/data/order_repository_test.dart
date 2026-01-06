import 'package:flutter_test/flutter_test.dart';
import 'package:street_cart_pos/data/repositories/cart_repository.dart';
import 'package:street_cart_pos/data/repositories/order_history_repository.dart';
import 'package:street_cart_pos/data/repositories/product_repository.dart';
import 'package:street_cart_pos/domain/models/enums.dart';
import 'package:street_cart_pos/domain/models/order.dart';
import 'package:street_cart_pos/domain/models/order_modifier_selection.dart';
import 'package:street_cart_pos/domain/models/order_product.dart';
import 'package:street_cart_pos/domain/models/payment.dart';
import 'package:street_cart_pos/domain/models/product.dart';
import '../../helpers/database_test_helper.dart';
import 'package:uuid/uuid.dart';

void main() {
  setupDatabaseTests();

  test(
    'OrderRepository: Create and Fetch Order with Items and Payment',
    () async {
      final productRepo = ProductRepository();
      final orderHistoryRepo = OrderHistoryRepository();

      // Setup: Create a product to sell
      final product = Product(
        id: const Uuid().v4(),
        name: 'Coffee',
        basePrice: 2.0,
      );
      await productRepo.createProduct(product);

      // 1. Create Order
      final orderItem = OrderProduct(
        id: const Uuid().v4(),
        quantity: 2,
        product: product,
      );
      final payment = Payment(
        id: const Uuid().v4(),
        type: PaymentMethod.cash,
        recieveAmountKHR: 0,
        recieveAmountUSD: 5.0,
        changeKhr: 0,
        changeUSD: 1.0,
      );

      final order = Order(
        id: const Uuid().v4(),
        timeStamp: DateTime.now(),
        orderType: OrderType.dineIn,
        paymentType: PaymentMethod.cash,
        cartStatus: CartStatus.finalized,
        orderStatus: OrderStatus.inPrep,
        orderProducts: [orderItem],
        payment: payment,
      );

      await orderHistoryRepo.createOrder(order);

      // 2. Fetch and Verify
      final orders = await orderHistoryRepo.getOrders();
      expect(orders.length, 1);

      final savedOrder = orders.first;
      expect(savedOrder.orderProducts.length, 1);
      expect(savedOrder.orderProducts.first.product?.name, 'Coffee');
      expect(savedOrder.payment?.recieveAmountUSD, 5.0);
    },
  );

  test('OrderRepository: addItemToDraftOrder creates draft + item', () async {
    final productRepo = ProductRepository();
    final cartRepo = CartRepository();

    final product = Product(id: const Uuid().v4(), name: 'Tea', basePrice: 2.0);
    await productRepo.createProduct(product);

    await cartRepo.addItemToDraftOrder(
      product: product,
      quantity: 2,
      unitPrice: 2.5,
      modifierSelections: const [
        OrderModifierSelection(groupName: 'Sugar Level', optionNames: ['50%']),
      ],
      note: 'No ice',
    );

    final draft = await cartRepo.getDraftOrder();
    expect(draft, isNotNull);
    expect(draft!.cartStatus, CartStatus.draft);
    expect(draft.orderStatus, isNull);
    expect(draft.orderProducts, hasLength(1));
    expect(draft.orderProducts.first.quantity, 2);
    expect(draft.orderProducts.first.product?.name, 'Tea');
    expect(draft.orderProducts.first.product?.basePrice, 2.5);
    expect(draft.orderProducts.first.note, 'No ice');
    expect(draft.orderProducts.first.modifierSelections, hasLength(1));
  });

  test('OrderRepository: finalizeDraftOrder sets statuses + payment', () async {
    final productRepo = ProductRepository();
    final cartRepo = CartRepository();
    final orderHistoryRepo = OrderHistoryRepository();

    final product = Product(id: const Uuid().v4(), name: 'Tea', basePrice: 2.0);
    await productRepo.createProduct(product);

    await cartRepo.addItemToDraftOrder(
      product: product,
      quantity: 1,
      unitPrice: 2.0,
      modifierSelections: const [],
      note: '',
    );

    final draft = await cartRepo.getDraftOrder();
    expect(draft, isNotNull);

    final payment = Payment(
      type: PaymentMethod.cash,
      recieveAmountKHR: 0,
      recieveAmountUSD: 5.0,
      changeKhr: 0,
      changeUSD: 3.0,
    );

    await cartRepo.checkoutDraftOrder(
      orderId: draft!.id,
      finalizedAt: DateTime.now(),
      orderType: OrderType.dineIn,
      paymentType: PaymentMethod.cash,
      payment: payment,
      vatPercentApplied: 10,
      usdToKhrRateApplied: 4000,
      roundingModeApplied: RoundingMode.roundUp,
    );

    expect(await cartRepo.getDraftOrder(), isNull);

    final orders = await orderHistoryRepo.getOrders();
    expect(orders, hasLength(1));
    expect(orders.first.cartStatus, CartStatus.finalized);
    expect(orders.first.orderStatus, OrderStatus.inPrep);
    expect(orders.first.payment, isNotNull);
  });

  test('OrderRepository: Update and Delete Order', () async {
    final orderHistoryRepo = OrderHistoryRepository();

    // 1. Create Initial Order
    final order = Order(
      id: const Uuid().v4(),
      timeStamp: DateTime.now(),
      orderType: OrderType.dineIn,
      paymentType: PaymentMethod.cash,
      cartStatus: CartStatus.finalized,
      orderStatus: OrderStatus.inPrep,
      orderProducts: [],
    );
    await orderHistoryRepo.createOrder(order);

    // 2. Update Status
    final updatedOrder = Order(
      id: order.id,
      timeStamp: order.timeStamp,
      orderType: order.orderType,
      paymentType: order.paymentType,
      cartStatus: order.cartStatus,
      orderStatus: OrderStatus.ready, // Changed
      orderProducts: [],
    );
    await orderHistoryRepo.updateOrder(updatedOrder);

    final fetched = (await orderHistoryRepo.getOrders()).first;
    expect(fetched.cartStatus, CartStatus.finalized);
    expect(fetched.orderStatus, OrderStatus.ready);

    // 3. Delete
    await orderHistoryRepo.deleteOrder(order.id);
    expect(await orderHistoryRepo.getOrders(), isEmpty);
  });
}
