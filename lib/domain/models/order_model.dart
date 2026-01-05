import 'package:uuid/uuid.dart';
import 'enums.dart';
import 'product_model.dart';

const uuid = Uuid();

// Payment
class Payment {
  final String id;
  final PaymentMethod type;

  final int recieveAmountKHR;
  final double recieveAmountUSD;
  final int changeKhr;
  final double changeUSD;

  Payment({
    String? id,
    required this.type,
    required this.recieveAmountKHR,
    required this.recieveAmountUSD,
    required this.changeKhr,
    required this.changeUSD,
  }) : id = id ?? uuid.v4();

  bool isValid() {
    // Business logic: Is the received amount >= total?
    // You can implement the math here
    return true;
  }
}

// OrderProduct
class OrderProduct {
  final String id;
  final int quantity;

  final Product? product;
  final List<OrderModifierSelection> modifierSelections;
  final String? note;

  OrderProduct({
    String? id,
    required this.quantity,
    this.product,
    this.modifierSelections = const [],
    this.note,
  }) : id = id ?? uuid.v4();

  double getLineTotal() {
    if (product != null) {
      return product!.basePrice * quantity;
    }
    return 0.0;
  }
}

class OrderModifierSelection {
  const OrderModifierSelection({
    required this.groupName,
    required this.optionNames,
  });

  final String groupName;
  final List<String> optionNames;
}

// Order
class Order {
  final String id;
  final DateTime timeStamp;
  OrderType orderType;
  PaymentMethod paymentType;
  CartStatus cartStatus;
  OrderStatus? orderStatus;

  Payment? payment;

  List<OrderProduct> orderProducts;

  Order({
    String? id,
    required this.timeStamp,
    required this.orderType,
    required this.paymentType,
    required this.cartStatus,
    required this.orderStatus,
    this.payment,
    this.orderProducts = const [],
  }) : id = id ?? uuid.v4();

  double getTotal() {
    return orderProducts.fold(0.0, (sum, item) => sum + item.getLineTotal());
  }

  bool get isDraft => cartStatus == CartStatus.draft;
  bool get isFinalized => cartStatus == CartStatus.finalized;

  void checkout() {
    if (payment != null && payment!.isValid()) {
      cartStatus = CartStatus.finalized;
      orderStatus ??= OrderStatus.inPrep;
    }
  }

  void updateOrderStatus(OrderStatus newStatus) {
    orderStatus = newStatus;
  }

  void updateOrderType(OrderType newType) {
    orderType = newType;
  }
}
