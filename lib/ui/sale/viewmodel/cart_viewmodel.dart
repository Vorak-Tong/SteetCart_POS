import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:street_cart_pos/data/repositories/order_repository.dart';
import 'package:street_cart_pos/data/repositories/sale_policy_repository.dart';
import 'package:street_cart_pos/domain/models/enums.dart';
import 'package:street_cart_pos/domain/models/order_model.dart';
import 'package:street_cart_pos/domain/models/sale_policy.dart';
import 'package:street_cart_pos/utils/command.dart';

class CartViewModel extends ChangeNotifier {
  CartViewModel({
    OrderRepository? orderRepository,
    SalePolicyRepository? salePolicyRepository,
  }) : _orderRepository = orderRepository ?? OrderRepository(),
       _salePolicyRepository =
           salePolicyRepository ?? SalePolicyRepositoryImpl() {
    loadCartCommand = CommandWithParam((_) => _loadCart());
    checkoutCommand = CommandWithParam((_) => _checkout());
    clearCartCommand = CommandWithParam((_) => _clearCart());

    loadCartCommand.addListener(notifyListeners);
    checkoutCommand.addListener(notifyListeners);
    clearCartCommand.addListener(notifyListeners);

    loadCartCommand.execute(null);
  }

  final OrderRepository _orderRepository;
  final SalePolicyRepository _salePolicyRepository;

  SalePolicy _policy = const SalePolicy(vat: 0, exchangeRate: 4000);

  late final CommandWithParam<void, void> loadCartCommand;
  late final CommandWithParam<void, void> checkoutCommand;
  late final CommandWithParam<void, void> clearCartCommand;

  double get vatRate => (_policy.vat.clamp(0, 100)) / 100.0;
  int get exchangeRateKhrPerUsd =>
      _policy.exchangeRate.round().clamp(1, 1000000);
  RoundingMode get roundingMode => _policy.roundingMode;

  Order? _draftOrder;

  OrderType _pendingOrderType = OrderType.dineIn;
  PaymentMethod _pendingPaymentMethod = PaymentMethod.cash;

  bool _hasLoadedOnce = false;

  double? _receivedUsd;
  int? _receivedKhr;
  String? _receivedUsdError;
  String? _receivedKhrError;

  bool get loading => loadCartCommand.running;
  bool get checkingOut => checkoutCommand.running;
  bool get clearingCart => clearCartCommand.running;
  bool get hasLoadedOnce => _hasLoadedOnce;

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
      _roundUsd(items.fold(0.0, (sum, item) => sum + item.getLineTotal()));
  int get vatPercent => _policy.vat.round().clamp(0, 100);
  double get vat => _roundUsd(subtotal * vatRate);
  double get grandTotalUsd => _roundUsd(subtotal + vat);
  int get grandTotalKhr => _toKhr(grandTotalUsd);

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
      final changeUsd = _roundUsd(_receivedUsd! - grandTotalUsd);
      return _toKhr(changeUsd);
    }
    return _receivedKhr! - grandTotalKhr;
  }

  bool get canCheckout =>
      !loading &&
      !checkingOut &&
      !clearingCart &&
      items.isNotEmpty &&
      hasSufficientPayment;

  Future<void> refreshFromDb() => loadCartCommand.execute(null);

  Future<void> checkout() => checkoutCommand.execute(null);

  Future<void> _loadCart() async {
    final results = await Future.wait<Object?>([
      _orderRepository.getDraftOrder(),
      _salePolicyRepository.getSalePolicy(),
    ]);
    _draftOrder = results[0] as Order?;
    _policy = results[1] as SalePolicy;

    if (_draftOrder != null) {
      _pendingOrderType = _draftOrder!.orderType;
      _pendingPaymentMethod = _draftOrder!.paymentType;
    }
    _hasLoadedOnce = true;
    notifyListeners();
  }

  Future<void> _checkout() async {
    final order = _draftOrder;
    if (order == null) {
      return;
    }
    if (!canCheckout) {
      return;
    }

    try {
      final receiveUsd = _hasValidReceivedUsd ? _receivedUsd! : 0.0;
      final receiveKhr = _hasValidReceivedKhr ? _receivedKhr! : 0;

      final changeUsd = () {
        if (receiveUsd <= 0) return 0.0;
        final candidate = _roundUsd(receiveUsd - grandTotalUsd);
        return candidate < 0 ? 0.0 : candidate;
      }();
      final changeKhr = (receiveKhr > 0)
          ? (receiveKhr - grandTotalKhr)
          : _toKhr(changeUsd);

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
        vatPercentApplied: vatPercent,
        usdToKhrRateApplied: exchangeRateKhrPerUsd,
        roundingModeApplied: roundingMode,
      );

      _draftOrder = null;
      _receivedUsd = null;
      _receivedKhr = null;
      _receivedUsdError = null;
      _receivedKhrError = null;
      notifyListeners();
    } finally {}
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
    await clearCartCommand.execute(null);
  }

  Future<void> _clearCart() async {
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

  int _toKhr(double usdAmount) {
    final value = _roundUsd(usdAmount) * exchangeRateKhrPerUsd;
    return switch (roundingMode) {
      RoundingMode.roundUp => value.ceil(),
      RoundingMode.roundDown => value.floor(),
    };
  }

  double _roundUsd(double value) => (value * 100).roundToDouble() / 100;

  @override
  void dispose() {
    loadCartCommand.removeListener(notifyListeners);
    checkoutCommand.removeListener(notifyListeners);
    clearCartCommand.removeListener(notifyListeners);
    super.dispose();
  }
}
