import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart'
    show ChangeNotifier, debugPrint, kDebugMode;
import 'package:street_cart_pos/data/repositories/cart_repository.dart';
import 'package:street_cart_pos/data/repositories/store_profile_repository.dart';
import 'package:street_cart_pos/data/repositories/order_history_repository.dart';
import 'package:street_cart_pos/data/repositories/sale_policy_repository.dart';
import 'package:street_cart_pos/domain/models/enums.dart';
import 'package:street_cart_pos/domain/models/order.dart';
import 'package:street_cart_pos/domain/models/order_product.dart';
import 'package:street_cart_pos/domain/models/payment.dart';
import 'package:street_cart_pos/domain/models/sale_policy.dart';
import 'package:street_cart_pos/ui/core/printing/bluetooth_printer_service.dart';
import 'package:street_cart_pos/ui/core/printing/receipt_escpos_builder.dart';
import 'package:street_cart_pos/ui/sale/utils/cart_badge_state.dart';
import 'package:street_cart_pos/utils/command.dart';

class CartViewModel extends ChangeNotifier {
  CartViewModel({
    CartRepository? cartRepository,
    OrderHistoryRepository? orderHistoryRepository,
    SalePolicyRepository? salePolicyRepository,
    StoreProfileRepository? storeProfileRepository,
    BluetoothPrinterService? printerService,
    ReceiptEscPosBuilder? receiptBuilder,
  }) : _cartRepository = cartRepository ?? CartRepository(),
       _orderHistoryRepository =
           orderHistoryRepository ?? OrderHistoryRepository(),
       _salePolicyRepository =
           salePolicyRepository ?? SalePolicyRepositoryImpl(),
       _storeProfileRepository =
           storeProfileRepository ?? StoreProfileRepositoryImpl(),
       _printerService = printerService ?? BluetoothPrinterService(),
       _receiptBuilder = receiptBuilder ?? const ReceiptEscPosBuilder() {
    loadCartCommand = CommandWithParam((_) => _loadCart());
    checkoutCommand = CommandWithParam((_) => _checkout());
    clearCartCommand = CommandWithParam((_) => _clearCart());

    loadCartCommand.addListener(notifyListeners);
    checkoutCommand.addListener(notifyListeners);
    clearCartCommand.addListener(notifyListeners);

    loadCartCommand.execute(null);
  }

  final CartRepository _cartRepository;
  final OrderHistoryRepository _orderHistoryRepository;
  final SalePolicyRepository _salePolicyRepository;
  final StoreProfileRepository _storeProfileRepository;
  final BluetoothPrinterService _printerService;
  final ReceiptEscPosBuilder _receiptBuilder;

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
    _draftOrder = await _cartRepository.getDraftOrder();
    _policy = await _salePolicyRepository.getSalePolicy();

    setCartItemLineCount(_draftOrder?.orderProducts.length ?? 0);

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
    if (items.isEmpty) return;
    if (!hasSufficientPayment) return;

    final finalizedAt = DateTime.now();
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

    final receiptOrder = Order(
      id: order.id,
      timeStamp: finalizedAt,
      orderType: order.orderType,
      paymentType: order.paymentType,
      cartStatus: CartStatus.finalized,
      orderStatus: OrderStatus.inPrep,
      vatPercentApplied: vatPercent,
      usdToKhrRateApplied: exchangeRateKhrPerUsd,
      roundingModeApplied: roundingMode,
      payment: payment,
      orderProducts: List<OrderProduct>.unmodifiable(order.orderProducts),
    );

    await _cartRepository.checkoutDraftOrder(
      orderId: order.id,
      finalizedAt: finalizedAt,
      orderType: order.orderType,
      paymentType: order.paymentType,
      payment: payment,
      vatPercentApplied: vatPercent,
      usdToKhrRateApplied: exchangeRateKhrPerUsd,
      roundingModeApplied: roundingMode,
    );

    _draftOrder = null;
    setCartItemLineCount(0);
    _receivedUsd = null;
    _receivedKhr = null;
    _receivedUsdError = null;
    _receivedKhrError = null;
    notifyListeners();

    unawaited(
      _autoPrintReceiptIfAvailable(
        receiptOrder,
        vatPercent: vatPercent,
        exchangeRateKhrPerUsd: exchangeRateKhrPerUsd,
        roundingMode: roundingMode,
      ),
    );
  }

  Future<void> _autoPrintReceiptIfAvailable(
    Order receiptOrder, {
    required int vatPercent,
    required int exchangeRateKhrPerUsd,
    required RoundingMode roundingMode,
  }) async {
    try {
      final printerSettings = await _printerService.getSettings();
      if (!printerSettings.isConfigured) {
        if (kDebugMode) {
          debugPrint('Auto-print skipped: no printer configured.');
        }
        return;
      }

      final displayNumber = await _orderHistoryRepository
          .getFinalizedOrderCountForDay(receiptOrder.timeStamp);
      final storeProfile = await _storeProfileRepository.getStoreProfile();
      final payload = _receiptBuilder.build(
        storeProfile: storeProfile,
        order: receiptOrder,
        printerSettings: printerSettings,
        displayNumber: displayNumber == 0 ? null : displayNumber,
        vatPercent: vatPercent,
        exchangeRateKhrPerUsd: exchangeRateKhrPerUsd,
        roundingMode: roundingMode,
      );

      await _printerService.printBytes(
        payload,
        bluetoothMacAddress: printerSettings.bluetoothMacAddress,
      );
      if (kDebugMode) {
        debugPrint(
          'Auto-print sent to ${printerSettings.deviceName ?? 'printer'} '
          '(${printerSettings.bluetoothMacAddress}).',
        );
      }
    } catch (_) {
      // Checkout should remain successful even if printing fails.
      if (kDebugMode) {
        debugPrint('Auto-print failed (ignored).');
      }
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

    _cartRepository
        .updateDraftOrderType(order.id, type)
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

    _cartRepository
        .updateDraftPaymentMethod(order.id, method)
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

    await _cartRepository.deleteDraftOrder();
    _draftOrder = null;
    setCartItemLineCount(0);

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

    _cartRepository
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
