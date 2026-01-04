import 'package:flutter_test/flutter_test.dart';
import 'package:street_cart_pos/data/repositories/order_repository.dart';
import 'package:street_cart_pos/data/repositories/product_repository.dart';
import 'package:street_cart_pos/domain/models/enums.dart';
import 'package:street_cart_pos/domain/models/order_model.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import '../../helpers/database_test_helper.dart';
import 'package:uuid/uuid.dart';

void main() {
  setupDatabaseTests();

  test('OrderRepository: Create and Fetch Order with Items and Payment', () async {
    final productRepo = ProductRepository();
    final orderRepo = OrderRepository();

    // Setup: Create a product to sell
    final product = Product(id: const Uuid().v4(), name: 'Coffee', basePrice: 2.0);
    await productRepo.createProduct(product);

    // 1. Create Order
    final orderItem = OrderProduct(id: const Uuid().v4(), quantity: 2, product: product);
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
      status: SaleStatus.finalized,
      orderProducts: [orderItem],
      payment: payment,
    );

    await orderRepo.createOrder(order);

    // 2. Fetch and Verify
    final orders = await orderRepo.getOrders();
    expect(orders.length, 1);
    
    final savedOrder = orders.first;
    expect(savedOrder.orderProducts.length, 1);
    expect(savedOrder.orderProducts.first.product?.name, 'Coffee');
    expect(savedOrder.payment?.recieveAmountUSD, 5.0);
  });

  test('OrderRepository: Update and Delete Order', () async {
    final orderRepo = OrderRepository();
    
    // 1. Create Initial Order
    final order = Order(
      id: const Uuid().v4(),
      timeStamp: DateTime.now(),
      orderType: OrderType.dineIn,
      paymentType: PaymentMethod.cash,
      status: SaleStatus.finalized,
      orderProducts: [],
    );
    await orderRepo.createOrder(order);

    // 2. Update Status
    final updatedOrder = Order(
      id: order.id,
      timeStamp: order.timeStamp,
      orderType: order.orderType,
      paymentType: order.paymentType,
      status: SaleStatus.finalized, // Changed
      orderProducts: [],
    );
    await orderRepo.updateOrder(updatedOrder);
    
    final fetched = (await orderRepo.getOrders()).first;
    expect(fetched.status, SaleStatus.finalized);

    // 3. Delete
    await orderRepo.deleteOrder(order.id);
    expect(await orderRepo.getOrders(), isEmpty);
  });
}