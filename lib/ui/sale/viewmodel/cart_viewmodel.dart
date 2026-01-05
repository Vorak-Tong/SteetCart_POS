import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:street_cart_pos/data/repositories/order_repository.dart';
import 'package:street_cart_pos/domain/models/enums.dart';
import 'package:street_cart_pos/domain/models/order_model.dart';

class CartViewModel extends ChangeNotifier {
  CartViewModel({OrderRepository? orderRepository})
    : _orderRepository = orderRepository ?? OrderRepository() {
    refreshFromDb();
  }

  final OrderRepository _orderRepository;

  static const double vatRate = 0.10;
  static const int exchangeRateKhrPerUsd = 4000;

  Order? _draftOrder;
  bool _loading = false;
  bool _checkingOut = false;

  OrderType _pendingOrderType = OrderType.dineIn;
  PaymentMethod _pendingPaymentMethod = PaymentMethod.cash;

  double? _receivedUsd;
  int? _receivedKhr;
  String? _receivedUsdError;
  String? _receivedKhrError;

  bool get loading => _loading;
  bool get checkingOut => _checkingOut;

  Order? get draftOrder => _draftOrder;
  bool get hasDraftOrder => _draftOrder != null;

  List<OrderProduct> get items =>
      List.unmodifiable(_draftOrder?.orderProducts ?? const <OrderProduct>[]);

  OrderType get orderType => _draftOrder?.orderType ?? _pendingOrderType;
  PaymentMethod get paymentMethod =>
      _draftOrder?.paymentType ?? _pendingPaymentMethod;

  String? get receivedUsdError => _receivedUsdError;
  String? get receivedKhrError => _receivedKhrError;

  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + item.getLineTotal());
  int get vatPercent => (vatRate * 100).round();
  double get vat => subtotal * vatRate;
  double get grandTotalUsd => subtotal + vat;
  int get grandTotalKhr => (grandTotalUsd * exchangeRateKhrPerUsd).round();

  bool get _hasValidReceivedUsd =>
      _receivedUsd != null && _receivedUsdError == null;
  bool get _hasValidReceivedKhr =>
      _receivedKhr != null && _receivedKhrError == null;

  bool get hasSufficientPayment {
    if (_hasValidReceivedUsd && _receivedUsd! >= grandTotalUsd) {
      return true;
    }
    if (_hasValidReceivedKhr && _receivedKhr! >= grandTotalKhr) {
      return true;
    }
    return false;
  }

  int? get changeKhr {
    if (!hasSufficientPayment) {
      return null;
    }
    if (_hasValidReceivedUsd) {
      final changeUsd = _receivedUsd! - grandTotalUsd;
      return (changeUsd * exchangeRateKhrPerUsd).round();
    }
    return _receivedKhr! - grandTotalKhr;
  }

  bool get canCheckout =>
      !_loading && !_checkingOut && items.isNotEmpty && hasSufficientPayment;

  Future<void> refreshFromDb() async {
    if (_loading) {
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      _draftOrder = await _orderRepository.getDraftOrder();

      if (_draftOrder != null) {
        _pendingOrderType = _draftOrder!.orderType;
        _pendingPaymentMethod = _draftOrder!.paymentType;
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> checkout() async {
    final order = _draftOrder;
    if (order == null) {
      return;
    }
    if (!canCheckout) {
      return;
    }

    _checkingOut = true;
    notifyListeners();

    try {
      final receiveUsd = _hasValidReceivedUsd ? _receivedUsd! : 0.0;
      final receiveKhr = _hasValidReceivedKhr ? _receivedKhr! : 0;

      final changeUsd = receiveUsd > 0 ? (receiveUsd - grandTotalUsd) : 0.0;
      final changeKhr = (receiveKhr > 0)
          ? (receiveKhr - grandTotalKhr)
          : (changeUsd * exchangeRateKhrPerUsd).round();

      final payment = Payment(
        type: paymentMethod,
        recieveAmountKHR: receiveKhr,
        recieveAmountUSD: receiveUsd,
        changeKhr: changeKhr,
        changeUSD: changeUsd,
      );

      await _orderRepository.finalizeDraftOrder(
        orderId: order.id,
        orderType: order.orderType,
        paymentType: order.paymentType,
        payment: payment,
      );

      _draftOrder = null;
      _receivedUsd = null;
      _receivedKhr = null;
      _receivedUsdError = null;
      _receivedKhrError = null;
    } finally {
      _checkingOut = false;
      notifyListeners();
    }
  }

  void setOrderType(OrderType type) {
    if (orderType == type) {
      return;
    }

    final order = _draftOrder;
    if (order == null) {
      _pendingOrderType = type;
      notifyListeners();
      return;
    }

    order.orderType = type;
    notifyListeners();

    _orderRepository
        .updateOrderMeta(order.id, orderType: type)
        .catchError((_) => refreshFromDb());
  }

  void setPaymentMethod(PaymentMethod method) {
    if (paymentMethod == method) {
      return;
    }

    final order = _draftOrder;
    if (order == null) {
      _pendingPaymentMethod = method;
      notifyListeners();
      return;
    }

    order.paymentType = method;
    notifyListeners();

    _orderRepository
        .updateOrderMeta(order.id, paymentType: method)
        .catchError((_) => refreshFromDb());
  }

  void setReceivedUsd(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      _receivedUsd = null;
      _receivedUsdError = null;
      notifyListeners();
      return;
    }

    final parsed = double.tryParse(trimmed);
    if (parsed == null) {
      _receivedUsd = null;
      _receivedUsdError = 'Invalid amount';
      notifyListeners();
      return;
    }

    if (parsed.isNegative) {
      _receivedUsd = null;
      _receivedUsdError = 'Must be non-negative';
      notifyListeners();
      return;
    }

    _receivedUsd = parsed;
    _receivedUsdError = null;

    _receivedKhr = null;
    _receivedKhrError = null;
    notifyListeners();
  }

  void setReceivedKhr(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      _receivedKhr = null;
      _receivedKhrError = null;
      notifyListeners();
      return;
    }

    final parsed = int.tryParse(trimmed);
    if (parsed == null) {
      _receivedKhr = null;
      _receivedKhrError = 'Invalid amount';
      notifyListeners();
      return;
    }

    if (parsed.isNegative) {
      _receivedKhr = null;
      _receivedKhrError = 'Must be non-negative';
      notifyListeners();
      return;
    }

    _receivedKhr = parsed;
    _receivedKhrError = null;

    _receivedUsd = null;
    _receivedUsdError = null;
    notifyListeners();
  }

  void incrementItemQuantity(String orderItemId) {
    _updateQuantity(orderItemId, delta: 1);
  }

  void decrementItemQuantity(String orderItemId) {
    _updateQuantity(orderItemId, delta: -1);
  }

  Future<void> clearCart() async {
    if (!hasDraftOrder) {
      return;
    }

    await _orderRepository.deleteDraftOrder();
    _draftOrder = null;

    _receivedUsd = null;
    _receivedKhr = null;
    _receivedUsdError = null;
    _receivedKhrError = null;

    notifyListeners();
  }

  void _updateQuantity(String orderItemId, {required int delta}) {
    final order = _draftOrder;
    if (order == null) {
      return;
    }

    final index = order.orderProducts.indexWhere((x) => x.id == orderItemId);
    if (index == -1) {
      return;
    }

    final current = order.orderProducts[index];
    final nextQuantity = current.quantity + delta;
    if (nextQuantity < 1) {
      return;
    }

    order.orderProducts = [
      ...order.orderProducts.sublist(0, index),
      OrderProduct(
        id: current.id,
        quantity: nextQuantity,
        product: current.product,
        modifierSelections: current.modifierSelections,
        note: current.note,
      ),
      ...order.orderProducts.sublist(index + 1),
    ];
    notifyListeners();

    _orderRepository
        .updateOrderItemQuantity(orderItemId, quantity: nextQuantity)
        .catchError((_) => refreshFromDb());
  }
}
