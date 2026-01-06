import 'dart:convert';

import '../../domain/models/enums.dart';
import '../../domain/models/order.dart';
import '../../domain/models/order_modifier_selection.dart';
import '../../domain/models/order_product.dart';
import '../../domain/models/payment.dart';
import '../../domain/models/product.dart';
import '../local/dao/order_dao.dart';
import '../local/dao/order_item_dao.dart';
import '../local/dao/payment_dao.dart';

typedef ProductLoader = Future<Product?> Function(String productId);

class OrderMapper {
  static CartStatus cartStatusFromOrderRow(Map<String, Object?> row) {
    final raw = row[OrderDao.colCartStatus] as String? ?? CartStatus.draft.name;
    return CartStatus.values.byName(raw);
  }

  static OrderStatus? orderStatusFromOrderRow(Map<String, Object?> row) {
    final raw = row[OrderDao.colOrderStatus] as String?;
    if (raw == null) return null;
    return OrderStatus.values.byName(raw);
  }

  static OrderType orderTypeFromOrderRow(Map<String, Object?> row) {
    final raw = row[OrderDao.colOrderType] as String? ?? OrderType.dineIn.name;
    return OrderType.values.byName(raw);
  }

  static PaymentMethod paymentMethodFromOrderRow(Map<String, Object?> row) {
    final raw =
        row[OrderDao.colPaymentType] as String? ?? PaymentMethod.cash.name;
    return PaymentMethod.values.byName(raw);
  }

  static RoundingMode? roundingModeFromOrderRow(Map<String, Object?> row) =>
      roundingModeFromRaw(row[OrderDao.colRoundingModeApplied] as String?);

  static RoundingMode? roundingModeFromRaw(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    return RoundingMode.values.any((x) => x.name == raw)
        ? RoundingMode.values.byName(raw)
        : null;
  }

  static String? modifierSelectionsToJson(
    List<OrderModifierSelection> selections,
  ) {
    if (selections.isEmpty) return null;
    return jsonEncode(
      selections
          .map((s) => {'groupName': s.groupName, 'optionNames': s.optionNames})
          .toList(growable: false),
    );
  }

  static List<OrderModifierSelection> modifierSelectionsFromJson(
    String? rawSelections,
  ) {
    if (rawSelections == null || rawSelections.trim().isEmpty) return const [];

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

  static Product? productSnapshotFromOrderItemRow(
    Map<String, Object?> itemRow,
  ) {
    final productId = itemRow[OrderItemDao.colProductId] as String?;
    final snapName = itemRow[OrderItemDao.colProductName] as String?;
    final snapUnitPrice = itemRow[OrderItemDao.colUnitPrice] as num?;
    if (snapName == null || snapUnitPrice == null) return null;

    final snapImage = itemRow[OrderItemDao.colProductImage] as String?;
    final snapDescription =
        itemRow[OrderItemDao.colProductDescription] as String?;

    return Product(
      id: productId,
      name: snapName,
      description: snapDescription,
      basePrice: snapUnitPrice.toDouble(),
      imagePath: snapImage,
      isActive: false,
    );
  }

  static OrderProduct orderProductFromRowPrefetched(
    Map<String, Object?> itemRow, {
    required Map<String, Product> productsById,
  }) {
    final productId = itemRow[OrderItemDao.colProductId] as String?;
    final product =
        productSnapshotFromOrderItemRow(itemRow) ??
        (productId == null ? null : productsById[productId]);

    final note = itemRow[OrderItemDao.colNote] as String?;
    final selections = modifierSelectionsFromJson(
      itemRow[OrderItemDao.colModifierSelections] as String?,
    );

    return OrderProduct(
      id: itemRow[OrderItemDao.colId] as String,
      quantity: itemRow[OrderItemDao.colQuantity] as int,
      product: product,
      modifierSelections: selections,
      note: note,
    );
  }

  static Future<OrderProduct> orderProductFromRowLazy(
    Map<String, Object?> itemRow, {
    required ProductLoader loadProduct,
  }) async {
    final productId = itemRow[OrderItemDao.colProductId] as String?;
    final snapshot = productSnapshotFromOrderItemRow(itemRow);
    final product =
        snapshot ?? (productId == null ? null : await loadProduct(productId));

    final note = itemRow[OrderItemDao.colNote] as String?;
    final selections = modifierSelectionsFromJson(
      itemRow[OrderItemDao.colModifierSelections] as String?,
    );

    return OrderProduct(
      id: itemRow[OrderItemDao.colId] as String,
      quantity: itemRow[OrderItemDao.colQuantity] as int,
      product: product,
      modifierSelections: selections,
      note: note,
    );
  }

  static Payment? paymentFromRow(Map<String, Object?>? paymentRow) {
    if (paymentRow == null) return null;

    return Payment(
      id: paymentRow[PaymentDao.colId] as String,
      type:
          PaymentMethod.values[paymentRow[PaymentDao.colPaymentMethod] as int],
      recieveAmountKHR: paymentRow[PaymentDao.colReceiveAmountKhr] as int,
      recieveAmountUSD: (paymentRow[PaymentDao.colReceiveAmountUsd] as num)
          .toDouble(),
      changeKhr: paymentRow[PaymentDao.colChangeKhr] as int,
      changeUSD: (paymentRow[PaymentDao.colChangeUsd] as num).toDouble(),
    );
  }

  static Future<Order> hydrateDraftOrder(
    Map<String, Object?> orderRow, {
    required List<Map<String, Object?>> itemRows,
    required ProductLoader loadProduct,
  }) async {
    final orderProducts = <OrderProduct>[];
    for (final itemRow in itemRows) {
      orderProducts.add(
        await orderProductFromRowLazy(itemRow, loadProduct: loadProduct),
      );
    }

    return Order(
      id: orderRow[OrderDao.colId] as String,
      timeStamp: DateTime.fromMillisecondsSinceEpoch(
        orderRow[OrderDao.colTimeStamp] as int,
      ),
      orderType: orderTypeFromOrderRow(orderRow),
      paymentType: paymentMethodFromOrderRow(orderRow),
      cartStatus: cartStatusFromOrderRow(orderRow),
      orderStatus: orderStatusFromOrderRow(orderRow),
      vatPercentApplied: orderRow[OrderDao.colVatPercentApplied] as int?,
      usdToKhrRateApplied: orderRow[OrderDao.colUsdToKhrRateApplied] as int?,
      roundingModeApplied: roundingModeFromOrderRow(orderRow),
      orderProducts: orderProducts,
      payment: null,
    );
  }

  static Order hydrateOrderPrefetched(
    Map<String, Object?> orderRow, {
    required List<Map<String, Object?>> itemRows,
    required Map<String, Object?>? paymentRow,
    required Map<String, Product> productsById,
  }) {
    final orderProducts = itemRows
        .map(
          (itemRow) => orderProductFromRowPrefetched(
            itemRow,
            productsById: productsById,
          ),
        )
        .toList(growable: false);

    return Order(
      id: orderRow[OrderDao.colId] as String,
      timeStamp: DateTime.fromMillisecondsSinceEpoch(
        orderRow[OrderDao.colTimeStamp] as int,
      ),
      orderType: orderTypeFromOrderRow(orderRow),
      paymentType: paymentMethodFromOrderRow(orderRow),
      cartStatus: cartStatusFromOrderRow(orderRow),
      orderStatus: orderStatusFromOrderRow(orderRow),
      vatPercentApplied: orderRow[OrderDao.colVatPercentApplied] as int?,
      usdToKhrRateApplied: orderRow[OrderDao.colUsdToKhrRateApplied] as int?,
      roundingModeApplied: roundingModeFromOrderRow(orderRow),
      orderProducts: orderProducts,
      payment: paymentFromRow(paymentRow),
    );
  }
}
