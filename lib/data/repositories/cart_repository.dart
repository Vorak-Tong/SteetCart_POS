import 'package:uuid/uuid.dart';

import '../../domain/models/enums.dart';
import '../../domain/models/order.dart';
import '../../domain/models/order_modifier_selection.dart';
import '../../domain/models/payment.dart';
import '../../domain/models/product.dart';
import '../mappers/order_mapper.dart';
import '../local/app_database.dart';
import '../local/dao/order_dao.dart';
import '../local/dao/order_item_dao.dart';
import '../local/dao/payment_dao.dart';
import '../local/dao/product_dao.dart';

class CartRepository {
  final _orderDao = OrderDao();
  final _orderItemDao = OrderItemDao();
  final _paymentDao = PaymentDao();
  final _productDao = ProductDao();
  static const _uuid = Uuid();

  Future<Order?> getDraftOrder() async {
    final db = await AppDatabase.instance();
    final rows = await db.query(
      OrderDao.tableName,
      where: '${OrderDao.colCartStatus} = ?',
      whereArgs: [CartStatus.draft.name],
      limit: 1,
      orderBy: '${OrderDao.colTimeStamp} DESC',
    );
    if (rows.isEmpty) {
      return null;
    }
    return _hydrateDraftOrderFromRow(rows.first);
  }

  Future<void> addItemToDraftOrder({
    required Product product,
    required int quantity,
    required double unitPrice,
    required List<OrderModifierSelection> modifierSelections,
    required String note,
    OrderType orderType = OrderType.dineIn,
    PaymentMethod paymentType = PaymentMethod.cash,
  }) async {
    final db = await AppDatabase.instance();

    await db.transaction((txn) async {
      final existing = await txn.query(
        OrderDao.tableName,
        columns: [OrderDao.colId],
        where: '${OrderDao.colCartStatus} = ?',
        whereArgs: [CartStatus.draft.name],
        limit: 1,
        orderBy: '${OrderDao.colTimeStamp} DESC',
      );

      final String orderId;
      if (existing.isNotEmpty) {
        orderId = existing.first[OrderDao.colId] as String;
      } else {
        orderId = _uuid.v4();
        final orderRow = <String, Object?>{
          OrderDao.colId: orderId,
          OrderDao.colTimeStamp: DateTime.now().millisecondsSinceEpoch,
          OrderDao.colOrderType: orderType.name,
          OrderDao.colPaymentType: paymentType.name,
          OrderDao.colCartStatus: CartStatus.draft.name,
          OrderDao.colOrderStatus: null,
          OrderDao.colVatPercentApplied: null,
          OrderDao.colUsdToKhrRateApplied: null,
          OrderDao.colRoundingModeApplied: null,
        };
        await _orderDao.insert(orderRow, txn: txn);
      }

      final selectionsJson = OrderMapper.modifierSelectionsToJson(
        modifierSelections,
      );

      await _orderItemDao.insert({
        OrderItemDao.colId: _uuid.v4(),
        OrderItemDao.colOrderId: orderId,
        OrderItemDao.colProductId: product.id,
        OrderItemDao.colProductName: product.name,
        OrderItemDao.colUnitPrice: unitPrice,
        OrderItemDao.colProductImage: product.imagePath,
        OrderItemDao.colProductDescription: product.description,
        OrderItemDao.colModifierSelections: selectionsJson,
        OrderItemDao.colNote: note.trim().isEmpty ? null : note.trim(),
        OrderItemDao.colQuantity: quantity,
      }, txn: txn);
    });
  }

  Future<void> deleteDraftOrder() async {
    final db = await AppDatabase.instance();
    await db.transaction((txn) async {
      final rows = await txn.query(
        OrderDao.tableName,
        columns: [OrderDao.colId],
        where: '${OrderDao.colCartStatus} = ?',
        whereArgs: [CartStatus.draft.name],
      );
      for (final row in rows) {
        final id = row[OrderDao.colId] as String?;
        if (id != null) {
          await _orderDao.delete(id, txn: txn);
        }
      }
    });
  }

  Future<void> updateDraftOrderType(String orderId, OrderType orderType) async {
    final db = await AppDatabase.instance();
    await db.transaction((txn) async {
      await _orderDao.update({
        OrderDao.colId: orderId,
        OrderDao.colOrderType: orderType.name,
      }, txn: txn);
    });
  }

  Future<void> updateDraftPaymentMethod(
    String orderId,
    PaymentMethod paymentType,
  ) async {
    final db = await AppDatabase.instance();
    await db.transaction((txn) async {
      await _orderDao.update({
        OrderDao.colId: orderId,
        OrderDao.colPaymentType: paymentType.name,
      }, txn: txn);
    });
  }

  Future<void> updateOrderItemQuantity(
    String orderItemId, {
    required int quantity,
  }) async {
    final db = await AppDatabase.instance();
    await db.transaction((txn) async {
      await _orderItemDao.updateQuantity(
        orderItemId,
        quantity: quantity,
        txn: txn,
      );
    });
  }

  Future<void> deleteOrderItem(String orderItemId) async {
    final db = await AppDatabase.instance();
    await db.transaction((txn) async {
      await _orderItemDao.delete(orderItemId, txn: txn);
    });
  }

  Future<void> checkoutDraftOrder({
    required String orderId,
    required DateTime finalizedAt,
    required OrderType orderType,
    required PaymentMethod paymentType,
    required Payment payment,
    required int vatPercentApplied,
    required int usdToKhrRateApplied,
    required RoundingMode roundingModeApplied,
  }) async {
    final db = await AppDatabase.instance();
    await db.transaction((txn) async {
      final orderUpdate = <String, Object?>{
        OrderDao.colId: orderId,
        OrderDao.colTimeStamp: finalizedAt.millisecondsSinceEpoch,
        OrderDao.colOrderType: orderType.name,
        OrderDao.colPaymentType: paymentType.name,
        OrderDao.colCartStatus: CartStatus.finalized.name,
        OrderDao.colOrderStatus: OrderStatus.inPrep.name,
        OrderDao.colVatPercentApplied: vatPercentApplied.clamp(0, 100),
        OrderDao.colUsdToKhrRateApplied: usdToKhrRateApplied,
        OrderDao.colRoundingModeApplied: roundingModeApplied.name,
      };

      await _orderDao.update(orderUpdate, txn: txn);

      await _paymentDao.deleteByOrderId(orderId, txn: txn);
      await _paymentDao.insert({
        PaymentDao.colId: payment.id,
        PaymentDao.colOrderId: orderId,
        PaymentDao.colPaymentMethod: payment.type.index,
        PaymentDao.colReceiveAmountKhr: payment.recieveAmountKHR,
        PaymentDao.colReceiveAmountUsd: payment.recieveAmountUSD,
        PaymentDao.colChangeKhr: payment.changeKhr,
        PaymentDao.colChangeUsd: payment.changeUSD,
      }, txn: txn);
    });
  }

  Future<Order> _hydrateDraftOrderFromRow(Map<String, Object?> row) async {
    final orderId = row[OrderDao.colId] as String;

    final itemRows = await _orderItemDao.getByOrderId(orderId);
    return OrderMapper.hydrateDraftOrder(
      row,
      itemRows: itemRows,
      loadProduct: _loadProductById,
    );
  }

  Future<Product?> _loadProductById(String productId) async {
    final productRow = await _productDao.getById(productId);
    if (productRow == null) return null;
    return Product(
      id: productRow[ProductDao.colId] as String,
      name: productRow[ProductDao.colName] as String,
      description: productRow[ProductDao.colDescription] as String?,
      basePrice: (productRow[ProductDao.colBasePrice] as num).toDouble(),
      imagePath: productRow[ProductDao.colImage] as String?,
      isActive: (productRow[ProductDao.colIsActive] as int? ?? 1) == 1,
    );
  }
}
