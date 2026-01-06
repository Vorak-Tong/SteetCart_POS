import '../local/app_database.dart';
import '../local/dao/order_dao.dart';
import '../local/dao/order_item_dao.dart';
import '../local/dao/payment_dao.dart';
import '../local/dao/product_dao.dart';
import '../../domain/models/order_model.dart';
import '../../domain/models/product_model.dart';
import '../../domain/models/enums.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class OrderRepository {
  final _orderDao = OrderDao();
  final _orderItemDao = OrderItemDao();
  final _paymentDao = PaymentDao();
  final _productDao = ProductDao();
  static const _uuid = Uuid();

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
          (row) => _hydrateOrderFromRowWithPrefetch(
            row,
            itemRows: itemsByOrderId[row[OrderDao.colId] as String] ?? const [],
            paymentRow: paymentByOrderId[row[OrderDao.colId] as String],
            productsById: productsById,
          ),
        )
        .toList(growable: false);
  }

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
    return _hydrateOrderFromRow(rows.first);
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

      final selectionsJson = modifierSelections.isEmpty
          ? null
          : jsonEncode(
              modifierSelections
                  .map(
                    (s) => {
                      'groupName': s.groupName,
                      'optionNames': s.optionNames,
                    },
                  )
                  .toList(growable: false),
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

  Future<Order> getOrCreateDraftOrder({
    required OrderType orderType,
    required PaymentMethod paymentType,
  }) async {
    final db = await AppDatabase.instance();

    final draftId = await db.transaction((txn) async {
      final rows = await txn.query(
        OrderDao.tableName,
        columns: [OrderDao.colId],
        where: '${OrderDao.colCartStatus} = ?',
        whereArgs: [CartStatus.draft.name],
        limit: 1,
        orderBy: '${OrderDao.colTimeStamp} DESC',
      );

      if (rows.isNotEmpty) {
        return rows.first[OrderDao.colId] as String;
      }

      final draft = Order(
        timeStamp: DateTime.now(),
        orderType: orderType,
        paymentType: paymentType,
        cartStatus: CartStatus.draft,
        orderStatus: null,
        orderProducts: const [],
      );

      final orderRow = <String, Object?>{
        OrderDao.colId: draft.id,
        OrderDao.colTimeStamp: draft.timeStamp.millisecondsSinceEpoch,
        OrderDao.colOrderType: draft.orderType.name,
        OrderDao.colPaymentType: draft.paymentType.name,
        OrderDao.colCartStatus: draft.cartStatus.name,
        OrderDao.colOrderStatus: null,
        OrderDao.colVatPercentApplied: null,
        OrderDao.colUsdToKhrRateApplied: null,
        OrderDao.colRoundingModeApplied: null,
      };
      await _orderDao.insert(orderRow, txn: txn);

      return draft.id;
    });

    final row = await _orderDao.getById(draftId);
    if (row == null) {
      throw StateError('Draft order not found after creation.');
    }
    return _hydrateOrderFromRow(row);
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

  Future<void> updateOrderMeta(
    String orderId, {
    OrderType? orderType,
    PaymentMethod? paymentType,
    CartStatus? cartStatus,
    OrderStatus? orderStatus,
  }) async {
    final db = await AppDatabase.instance();
    await db.transaction((txn) async {
      final update = <String, Object?>{OrderDao.colId: orderId};
      if (orderType != null) {
        update[OrderDao.colOrderType] = orderType.name;
      }
      if (paymentType != null) {
        update[OrderDao.colPaymentType] = paymentType.name;
      }
      if (cartStatus != null) {
        update[OrderDao.colCartStatus] = cartStatus.name;
      }
      if (orderStatus != null) {
        update[OrderDao.colOrderStatus] = orderStatus.name;
      }
      if (update.length == 1) {
        return;
      }

      await _orderDao.update(update, txn: txn);
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

  Future<void> finalizeDraftOrder({
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

  Future<Order> _hydrateOrderFromRow(Map<String, Object?> row) async {
    final orderId = row[OrderDao.colId] as String;

    final cartStatusRaw = row[OrderDao.colCartStatus] as String? ?? 'draft';
    final cartStatus = CartStatus.values.byName(cartStatusRaw);
    final orderStatusRaw = row[OrderDao.colOrderStatus] as String?;
    final OrderStatus? orderStatus = orderStatusRaw == null
        ? null
        : OrderStatus.values.byName(orderStatusRaw);

    // Fetch Items
    final itemRows = await _orderItemDao.getByOrderId(orderId);
    final List<OrderProduct> orderProducts = [];

    for (final itemRow in itemRows) {
      final productId = itemRow[OrderItemDao.colProductId] as String?;
      Product? product;

      final snapName = itemRow[OrderItemDao.colProductName] as String?;
      final snapUnitPrice = itemRow[OrderItemDao.colUnitPrice] as num?;
      final snapImage = itemRow[OrderItemDao.colProductImage] as String?;
      final snapDescription =
          itemRow[OrderItemDao.colProductDescription] as String?;

      if (snapName != null && snapUnitPrice != null) {
        product = Product(
          id: productId,
          name: snapName,
          description: snapDescription,
          basePrice: snapUnitPrice.toDouble(),
          imagePath: snapImage,
          isActive: false,
        );
      } else if (productId != null) {
        final productRow = await _productDao.getById(productId);
        if (productRow != null) {
          product = Product(
            id: productRow[ProductDao.colId] as String,
            name: productRow[ProductDao.colName] as String,
            description: productRow[ProductDao.colDescription] as String?,
            basePrice: (productRow[ProductDao.colBasePrice] as num).toDouble(),
            imagePath: productRow[ProductDao.colImage] as String?,
            isActive: (productRow[ProductDao.colIsActive] as int? ?? 1) == 1,
          );
        }
      }

      final note = itemRow[OrderItemDao.colNote] as String?;

      List<OrderModifierSelection> selections = const [];
      final rawSelections =
          itemRow[OrderItemDao.colModifierSelections] as String?;
      if (rawSelections != null && rawSelections.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(rawSelections);
          if (decoded is List) {
            final parsed = <OrderModifierSelection>[];
            for (final entry in decoded) {
              if (entry is! Map) continue;
              final groupName = entry['groupName'];
              final optionNames = entry['optionNames'];
              if (groupName is! String || optionNames is! List) continue;
              parsed.add(
                OrderModifierSelection(
                  groupName: groupName,
                  optionNames: optionNames.whereType<String>().toList(
                    growable: false,
                  ),
                ),
              );
            }
            selections = parsed;
          }
        } catch (_) {
          // Ignore parsing errors and treat as no selections.
        }
      }

      orderProducts.add(
        OrderProduct(
          id: itemRow[OrderItemDao.colId] as String,
          quantity: itemRow[OrderItemDao.colQuantity] as int,
          product: product,
          modifierSelections: selections,
          note: note,
        ),
      );
    }

    // Fetch Payment
    Payment? payment;
    final paymentRow = await _paymentDao.getByOrderId(orderId);
    if (paymentRow != null) {
      payment = Payment(
        id: paymentRow[PaymentDao.colId] as String,
        type: PaymentMethod
            .values[paymentRow[PaymentDao.colPaymentMethod] as int],
        recieveAmountKHR: paymentRow[PaymentDao.colReceiveAmountKhr] as int,
        recieveAmountUSD: (paymentRow[PaymentDao.colReceiveAmountUsd] as num)
            .toDouble(),
        changeKhr: paymentRow[PaymentDao.colChangeKhr] as int,
        changeUSD: (paymentRow[PaymentDao.colChangeUsd] as num).toDouble(),
      );
    }

    return Order(
      id: orderId,
      timeStamp: DateTime.fromMillisecondsSinceEpoch(
        row[OrderDao.colTimeStamp] as int,
      ),
      orderType: OrderType.values.byName(
        row[OrderDao.colOrderType] as String? ?? 'dineIn',
      ),
      paymentType: PaymentMethod.values.byName(
        row[OrderDao.colPaymentType] as String? ?? 'cash',
      ),
      cartStatus: cartStatus,
      orderStatus: orderStatus,
      vatPercentApplied: row[OrderDao.colVatPercentApplied] as int?,
      usdToKhrRateApplied: row[OrderDao.colUsdToKhrRateApplied] as int?,
      roundingModeApplied: _parseRoundingMode(
        row[OrderDao.colRoundingModeApplied] as String?,
      ),
      orderProducts: orderProducts,
      payment: payment,
    );
  }

  Order _hydrateOrderFromRowWithPrefetch(
    Map<String, Object?> row, {
    required List<Map<String, Object?>> itemRows,
    required Map<String, Object?>? paymentRow,
    required Map<String, Product> productsById,
  }) {
    final orderId = row[OrderDao.colId] as String;

    final cartStatusRaw = row[OrderDao.colCartStatus] as String? ?? 'draft';
    final cartStatus = CartStatus.values.byName(cartStatusRaw);
    final orderStatusRaw = row[OrderDao.colOrderStatus] as String?;
    final OrderStatus? orderStatus = orderStatusRaw == null
        ? null
        : OrderStatus.values.byName(orderStatusRaw);

    final orderProducts = itemRows
        .map((itemRow) {
          final productId = itemRow[OrderItemDao.colProductId] as String?;

          Product? product;
          final snapName = itemRow[OrderItemDao.colProductName] as String?;
          final snapUnitPrice = itemRow[OrderItemDao.colUnitPrice] as num?;
          final snapImage = itemRow[OrderItemDao.colProductImage] as String?;
          final snapDescription =
              itemRow[OrderItemDao.colProductDescription] as String?;

          if (snapName != null && snapUnitPrice != null) {
            product = Product(
              id: productId,
              name: snapName,
              description: snapDescription,
              basePrice: snapUnitPrice.toDouble(),
              imagePath: snapImage,
              isActive: false,
            );
          } else if (productId != null) {
            product = productsById[productId];
          }

          final note = itemRow[OrderItemDao.colNote] as String?;
          final selections = _parseModifierSelections(
            itemRow[OrderItemDao.colModifierSelections] as String?,
          );

          return OrderProduct(
            id: itemRow[OrderItemDao.colId] as String,
            quantity: itemRow[OrderItemDao.colQuantity] as int,
            product: product,
            modifierSelections: selections,
            note: note,
          );
        })
        .toList(growable: false);

    Payment? payment;
    if (paymentRow != null) {
      payment = Payment(
        id: paymentRow[PaymentDao.colId] as String,
        type: PaymentMethod
            .values[paymentRow[PaymentDao.colPaymentMethod] as int],
        recieveAmountKHR: paymentRow[PaymentDao.colReceiveAmountKhr] as int,
        recieveAmountUSD: (paymentRow[PaymentDao.colReceiveAmountUsd] as num)
            .toDouble(),
        changeKhr: paymentRow[PaymentDao.colChangeKhr] as int,
        changeUSD: (paymentRow[PaymentDao.colChangeUsd] as num).toDouble(),
      );
    }

    return Order(
      id: orderId,
      timeStamp: DateTime.fromMillisecondsSinceEpoch(
        row[OrderDao.colTimeStamp] as int,
      ),
      orderType: OrderType.values.byName(
        row[OrderDao.colOrderType] as String? ?? 'dineIn',
      ),
      paymentType: PaymentMethod.values.byName(
        row[OrderDao.colPaymentType] as String? ?? 'cash',
      ),
      cartStatus: cartStatus,
      orderStatus: orderStatus,
      vatPercentApplied: row[OrderDao.colVatPercentApplied] as int?,
      usdToKhrRateApplied: row[OrderDao.colUsdToKhrRateApplied] as int?,
      roundingModeApplied: _parseRoundingMode(
        row[OrderDao.colRoundingModeApplied] as String?,
      ),
      orderProducts: orderProducts,
      payment: payment,
    );
  }

  RoundingMode? _parseRoundingMode(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    return RoundingMode.values.any((x) => x.name == raw)
        ? RoundingMode.values.byName(raw)
        : null;
  }

  List<OrderModifierSelection> _parseModifierSelections(String? rawSelections) {
    if (rawSelections == null || rawSelections.trim().isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(rawSelections);
      if (decoded is! List) return const [];

      final parsed = <OrderModifierSelection>[];
      for (final entry in decoded) {
        if (entry is! Map) continue;
        final groupName = entry['groupName'];
        final optionNames = entry['optionNames'];
        if (groupName is! String || optionNames is! List) continue;
        parsed.add(
          OrderModifierSelection(
            groupName: groupName,
            optionNames: optionNames.whereType<String>().toList(
              growable: false,
            ),
          ),
        );
      }
      return parsed;
    } catch (_) {
      return const [];
    }
  }

  Future<void> createOrder(Order order) async {
    final db = await AppDatabase.instance();

    await db.transaction((txn) async {
      // Insert Order
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

      // Insert Items
      for (final item in order.orderProducts) {
        final p = item.product;
        final selectionsJson = item.modifierSelections.isEmpty
            ? null
            : jsonEncode(
                item.modifierSelections
                    .map(
                      (s) => {
                        'groupName': s.groupName,
                        'optionNames': s.optionNames,
                      },
                    )
                    .toList(growable: false),
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

      // Insert Payment (if exists)
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
      // Update Order
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

      // Update Items (Delete all and re-insert)
      await _orderItemDao.deleteByOrderId(order.id, txn: txn);
      for (final item in order.orderProducts) {
        final p = item.product;
        final selectionsJson = item.modifierSelections.isEmpty
            ? null
            : jsonEncode(
                item.modifierSelections
                    .map(
                      (s) => {
                        'groupName': s.groupName,
                        'optionNames': s.optionNames,
                      },
                    )
                    .toList(growable: false),
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

      // Update Payment
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
