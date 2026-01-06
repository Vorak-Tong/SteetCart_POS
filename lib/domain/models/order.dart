import 'enums.dart';
import 'model_ids.dart';
import 'order_product.dart';
import 'payment.dart';

class Order {
  final String id;
  final DateTime timeStamp;
  OrderType orderType;
  PaymentMethod paymentType;
  CartStatus cartStatus;
  OrderStatus? orderStatus;

  final int? vatPercentApplied;
  final int? usdToKhrRateApplied;
  final RoundingMode? roundingModeApplied;

  Payment? payment;

  List<OrderProduct> orderProducts;

  Order({
    String? id,
    required this.timeStamp,
    required this.orderType,
    required this.paymentType,
    required this.cartStatus,
    required this.orderStatus,
    this.vatPercentApplied,
    this.usdToKhrRateApplied,
    this.roundingModeApplied,
    this.payment,
    this.orderProducts = const [],
  }) : id = id ?? uuid.v4();

  double getTotal() {
    return orderProducts.fold(0.0, (sum, item) => sum + item.getLineTotal());
  }

  bool get isDraft => cartStatus == CartStatus.draft;
  bool get isFinalized => cartStatus == CartStatus.finalized;

  void updateOrderStatus(OrderStatus newStatus) {
    orderStatus = newStatus;
  }
}
