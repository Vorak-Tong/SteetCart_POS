import 'package:sqflite/sqflite.dart';
import '../local/app_database.dart';
import '../local/dao/order_dao.dart';
import '../local/dao/order_item_dao.dart';
import '../local/dao/payment_dao.dart';
import '../local/dao/product_dao.dart';
import '../../domain/models/order_model.dart';
import '../../domain/models/product_model.dart';
import '../../domain/models/enums.dart';

class OrderRepository {
  final _orderDao = OrderDao();
  final _orderItemDao = OrderItemDao();
  final _paymentDao = PaymentDao();
  final _productDao = ProductDao();

  Future<List<Order>> getOrders() async {
    final orderRows = await _orderDao.getAll();
    final List<Order> orders = [];

    for (final row in orderRows) {
      final orderId = row[OrderDao.colId] as String;
      
      // Fetch Items
      final itemRows = await _orderItemDao.getByOrderId(orderId);
      final List<OrderProduct> orderProducts = [];
      
      for (final itemRow in itemRows) {
        final productId = itemRow[OrderItemDao.colProductId] as String?;
        Product? product;
        
        if (productId != null) {
          final productRow = await _productDao.getById(productId);
          if (productRow != null) {
            product = Product(
              id: productRow[ProductDao.colId] as String,
              name: productRow[ProductDao.colName] as String,
              basePrice: (productRow[ProductDao.colBasePrice] as num).toDouble(),
              image: productRow[ProductDao.colImage] as String?,
            );
          }
        }

        orderProducts.add(OrderProduct(
          id: itemRow[OrderItemDao.colId] as String,
          quantity: itemRow[OrderItemDao.colQuantity] as int,
          product: product,
        ));
      }

      // Fetch Payment
      Payment? payment;
      final paymentRow = await _paymentDao.getByOrderId(orderId);
      if (paymentRow != null) {
        payment = Payment(
          id: paymentRow[PaymentDao.colId] as String,
          type: PaymentMethod.values[paymentRow[PaymentDao.colPaymentMethod] as int],
          recieveAmountKHR: paymentRow[PaymentDao.colReceiveAmountKhr] as int,
          recieveAmountUSD: (paymentRow[PaymentDao.colReceiveAmountUsd] as num).toDouble(),
          changeKhr: paymentRow[PaymentDao.colChangeKhr] as int,
          changeUSD: (paymentRow[PaymentDao.colChangeUsd] as num).toDouble(),
        );
      }

      orders.add(Order(
        id: orderId,
        timeStamp: DateTime.fromMillisecondsSinceEpoch(row[OrderDao.colTimeStamp] as int),
        orderType: OrderType.values[row[OrderDao.colOrderType] as int],
        paymentType: PaymentMethod.values[row[OrderDao.colPaymentType] as int],
        status: SaleStatus.values[row[OrderDao.colStatus] as int],
        orderProducts: orderProducts,
        payment: payment,
      ));
    }

    return orders;
  }

  Future<void> createOrder(Order order) async {
    final db = await AppDatabase.instance();
    
    await db.transaction((txn) async {
      // 1. Insert Order
      await _orderDao.insert({
        OrderDao.colId: order.id,
        OrderDao.colTimeStamp: order.timeStamp.millisecondsSinceEpoch,
        OrderDao.colOrderType: order.orderType.index,
        OrderDao.colPaymentType: order.paymentType.index,
        OrderDao.colStatus: order.status.index,
      }, txn: txn);

      // 2. Insert Items
      for (final item in order.orderProducts) {
        await _orderItemDao.insert({
          OrderItemDao.colId: item.id,
          OrderItemDao.colOrderId: order.id,
          OrderItemDao.colProductId: item.product?.id,
          OrderItemDao.colQuantity: item.quantity,
        }, txn: txn);
      }

      // 3. Insert Payment (if exists)
      if (order.payment != null) {
        await _paymentDao.insert({
          PaymentDao.colId: order.payment!.id,
          PaymentDao.colOrderId: order.id,
          PaymentDao.colPaymentMethod: order.payment!.type.index,
          PaymentDao.colReceiveAmountKhr: order.payment!.recieveAmountKHR,
          PaymentDao.colReceiveAmountUsd: order.payment!.recieveAmountUSD,
          PaymentDao.colChangeKhr: order.payment!.changeKhr,
          PaymentDao.colChangeUsd: order.payment!.changeUSD,
        }, txn: txn);
      }
    });
  }

  Future<void> updateOrder(Order order) async {
    final db = await AppDatabase.instance();
    
    await db.transaction((txn) async {
      // 1. Update Order
      await _orderDao.update({
        OrderDao.colId: order.id,
        OrderDao.colTimeStamp: order.timeStamp.millisecondsSinceEpoch,
        OrderDao.colOrderType: order.orderType.index,
        OrderDao.colPaymentType: order.paymentType.index,
        OrderDao.colStatus: order.status.index,
      }, txn: txn);

      // 2. Update Items (Delete all and re-insert)
      await _orderItemDao.deleteByOrderId(order.id, txn: txn);
      for (final item in order.orderProducts) {
        await _orderItemDao.insert({
          OrderItemDao.colId: item.id,
          OrderItemDao.colOrderId: order.id,
          OrderItemDao.colProductId: item.product?.id,
          OrderItemDao.colQuantity: item.quantity,
        }, txn: txn);
      }

      // 3. Update Payment
      await _paymentDao.deleteByOrderId(order.id, txn: txn);
      if (order.payment != null) {
        await _paymentDao.insert({
          PaymentDao.colId: order.payment!.id,
          PaymentDao.colOrderId: order.id,
          PaymentDao.colPaymentMethod: order.payment!.type.index,
          PaymentDao.colReceiveAmountKhr: order.payment!.recieveAmountKHR,
          PaymentDao.colReceiveAmountUsd: order.payment!.recieveAmountUSD,
          PaymentDao.colChangeKhr: order.payment!.changeKhr,
          PaymentDao.colChangeUsd: order.payment!.changeUSD,
        }, txn: txn);
      }
    });
  }

  Future<void> deleteOrder(String id) async {
    await _orderDao.delete(id);
  }
}