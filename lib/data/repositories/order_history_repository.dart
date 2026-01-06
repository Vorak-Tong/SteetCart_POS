import '../../domain/models/enums.dart';
import '../../domain/models/order.dart';
import '../../domain/models/order_modifier_selection.dart';
import '../../domain/models/order_product.dart';
import '../../domain/models/payment.dart';
import '../../domain/models/product.dart';
import '../mappers/order_mapper.dart';
import '../local/app_database.dart';
import '../local/dao/order_dao.dart';
import '../local/dao/order_item_dao.dart';
import '../local/dao/payment_dao.dart';
import '../local/dao/product_dao.dart';

class OrderHistoryRepository {
  final _orderDao = OrderDao();
  final _orderItemDao = OrderItemDao();
  final _paymentDao = PaymentDao();
  final _productDao = ProductDao();

  Future<List<Order>> getOrders() async {
    final orderRows = await _orderDao.getAll();
    if (orderRows.isEmpty) {
      return const [];
    }

    final orderIds = orderRows
        .map((row) => row[OrderDao.colId] as String)
        .toList(growable: false);

    final results = await Future.wait<Object?>([
      _orderItemDao.getByOrderIds(orderIds),
      _paymentDao.getByOrderIds(orderIds),
    ]);

    final itemRows = results[0] as List<Map<String, Object?>>;
    final paymentRows = results[1] as List<Map<String, Object?>>;

    final missingProductIds = <String>{};
    for (final row in itemRows) {
      final productId = row[OrderItemDao.colProductId] as String?;
      if (productId == null) continue;
      final snapName = row[OrderItemDao.colProductName] as String?;
      final snapUnitPrice = row[OrderItemDao.colUnitPrice] as num?;
      if (snapName == null || snapUnitPrice == null) {
        missingProductIds.add(productId);
      }
    }

    final productsById = <String, Product>{};
    if (missingProductIds.isNotEmpty) {
      final productRows = await _productDao.getByIds(
        missingProductIds.toList(growable: false),
      );
      for (final productRow in productRows) {
        final id = productRow[ProductDao.colId] as String?;
        if (id == null) continue;
        productsById[id] = Product(
          id: id,
          name: productRow[ProductDao.colName] as String,
          description: productRow[ProductDao.colDescription] as String?,
          basePrice: (productRow[ProductDao.colBasePrice] as num).toDouble(),
          imagePath: productRow[ProductDao.colImage] as String?,
          isActive: (productRow[ProductDao.colIsActive] as int? ?? 1) == 1,
        );
      }
    }

    final itemsByOrderId = <String, List<Map<String, Object?>>>{};
    for (final row in itemRows) {
      final orderId = row[OrderItemDao.colOrderId] as String?;
      if (orderId == null) continue;
      (itemsByOrderId[orderId] ??= <Map<String, Object?>>[]).add(row);
    }

    final paymentByOrderId = <String, Map<String, Object?>>{};
    for (final row in paymentRows) {
      final orderId = row[PaymentDao.colOrderId] as String?;
      if (orderId == null) continue;
      paymentByOrderId[orderId] = row;
    }

    return orderRows
        .map(
          (row) => OrderMapper.hydrateOrderPrefetched(
            row,
            itemRows: itemsByOrderId[row[OrderDao.colId] as String] ?? const [],
            paymentRow: paymentByOrderId[row[OrderDao.colId] as String],
            productsById: productsById,
          ),
        )
        .toList(growable: false);
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final db = await AppDatabase.instance();
    await db.transaction((txn) async {
      await _orderDao.update({
        OrderDao.colId: orderId,
        OrderDao.colCartStatus: CartStatus.finalized.name,
        OrderDao.colOrderStatus: status.name,
      }, txn: txn);
    });
  }

  Future<int> getFinalizedOrderCountForDay(DateTime day) async {
    final db = await AppDatabase.instance();
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    final results = await db.rawQuery(
      '''
      SELECT COUNT(*) AS c
      FROM orders
      WHERE cart_status = ?
        AND order_status IS NOT NULL
        AND timestamp >= ?
        AND timestamp < ?
      ''',
      [
        CartStatus.finalized.name,
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      ],
    );

    if (results.isEmpty) return 0;
    return (results.first['c'] as num?)?.toInt() ?? 0;
  }

  Future<void> createOrder(Order order) async {
    final db = await AppDatabase.instance();

    await db.transaction((txn) async {
      final orderRow = <String, Object?>{
        OrderDao.colId: order.id,
        OrderDao.colTimeStamp: order.timeStamp.millisecondsSinceEpoch,
        OrderDao.colOrderType: order.orderType.name,
        OrderDao.colPaymentType: order.paymentType.name,
        OrderDao.colCartStatus: order.cartStatus.name,
        OrderDao.colOrderStatus: order.orderStatus?.name,
        OrderDao.colVatPercentApplied: order.vatPercentApplied,
        OrderDao.colUsdToKhrRateApplied: order.usdToKhrRateApplied,
        OrderDao.colRoundingModeApplied: order.roundingModeApplied?.name,
      };
      await _orderDao.insert(orderRow, txn: txn);

      for (final item in order.orderProducts) {
        final p = item.product;
        final selectionsJson = OrderMapper.modifierSelectionsToJson(
          item.modifierSelections,
        );
        await _orderItemDao.insert({
          OrderItemDao.colId: item.id,
          OrderItemDao.colOrderId: order.id,
          OrderItemDao.colProductId: p?.id,
          OrderItemDao.colProductName: p?.name,
          OrderItemDao.colUnitPrice: p?.basePrice,
          OrderItemDao.colProductImage: p?.imagePath,
          OrderItemDao.colProductDescription: p?.description,
          OrderItemDao.colModifierSelections: selectionsJson,
          OrderItemDao.colNote: (item.note?.trim().isEmpty ?? true)
              ? null
              : item.note?.trim(),
          OrderItemDao.colQuantity: item.quantity,
        }, txn: txn);
      }

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
      final orderRow = <String, Object?>{
        OrderDao.colId: order.id,
        OrderDao.colTimeStamp: order.timeStamp.millisecondsSinceEpoch,
        OrderDao.colOrderType: order.orderType.name,
        OrderDao.colPaymentType: order.paymentType.name,
        OrderDao.colCartStatus: order.cartStatus.name,
        OrderDao.colOrderStatus: order.orderStatus?.name,
        OrderDao.colVatPercentApplied: order.vatPercentApplied,
        OrderDao.colUsdToKhrRateApplied: order.usdToKhrRateApplied,
        OrderDao.colRoundingModeApplied: order.roundingModeApplied?.name,
      };
      await _orderDao.update(orderRow, txn: txn);

      await _orderItemDao.deleteByOrderId(order.id, txn: txn);
      for (final item in order.orderProducts) {
        final p = item.product;
        final selectionsJson = OrderMapper.modifierSelectionsToJson(
          item.modifierSelections,
        );
        await _orderItemDao.insert({
          OrderItemDao.colId: item.id,
          OrderItemDao.colOrderId: order.id,
          OrderItemDao.colProductId: p?.id,
          OrderItemDao.colProductName: p?.name,
          OrderItemDao.colUnitPrice: p?.basePrice,
          OrderItemDao.colProductImage: p?.imagePath,
          OrderItemDao.colProductDescription: p?.description,
          OrderItemDao.colModifierSelections: selectionsJson,
          OrderItemDao.colNote: (item.note?.trim().isEmpty ?? true)
              ? null
              : item.note?.trim(),
          OrderItemDao.colQuantity: item.quantity,
        }, txn: txn);
      }

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
