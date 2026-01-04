import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:street_cart_pos/domain/models/enums.dart';

class CartViewModel extends ChangeNotifier {
  CartViewModel() {
    _items = _mockCartItems();
  }

  static const double vatRate = 0.10;
  static const int exchangeRateKhrPerUsd = 4000;

  late List<CartLineItem> _items;

  OrderType _orderType = OrderType.dineIn;
  PaymentMethod _paymentMethod = PaymentMethod.cash;

  double? _receivedUsd;
  int? _receivedKhr;
  String? _receivedUsdError;
  String? _receivedKhrError;

  List<CartLineItem> get items => List.unmodifiable(_items);
  OrderType get orderType => _orderType;
  PaymentMethod get paymentMethod => _paymentMethod;

  String? get receivedUsdError => _receivedUsdError;
  String? get receivedKhrError => _receivedKhrError;

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.lineTotal);
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

  bool get canCheckout => _items.isNotEmpty && hasSufficientPayment;

  void setOrderType(OrderType type) {
    if (_orderType == type) {
      return;
    }
    _orderType = type;
    notifyListeners();
  }

  void setPaymentMethod(PaymentMethod method) {
    if (_paymentMethod == method) {
      return;
    }
    _paymentMethod = method;
    notifyListeners();
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

  void incrementItemQuantity(String id) {
    _updateQuantity(id, delta: 1);
  }

  void decrementItemQuantity(String id) {
    _updateQuantity(id, delta: -1);
  }

  void clearCart() {
    if (_items.isEmpty) {
      return;
    }
    _items = const [];
    _receivedUsd = null;
    _receivedKhr = null;
    _receivedUsdError = null;
    _receivedKhrError = null;
    notifyListeners();
  }

  void _updateQuantity(String id, {required int delta}) {
    final index = _items.indexWhere((x) => x.id == id);
    if (index == -1) {
      return;
    }

    final current = _items[index];
    final nextQuantity = current.quantity + delta;
    if (nextQuantity < 1) {
      return;
    }

    _items = [
      ..._items.sublist(0, index),
      current.copyWith(quantity: nextQuantity),
      ..._items.sublist(index + 1),
    ];
    notifyListeners();
  }
}

class CartLineItem {
  const CartLineItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.modifierSelections = const [],
    this.notes,
    this.imagePath,
  });

  final String id;
  final String name;
  final int quantity;
  final double unitPrice;
  final List<CartModifierSelection> modifierSelections;
  final String? notes;
  final String? imagePath;

  double get lineTotal => unitPrice * quantity;

  CartLineItem copyWith({
    int? quantity,
    double? unitPrice,
    List<CartModifierSelection>? modifierSelections,
    String? notes,
    String? imagePath,
  }) {
    return CartLineItem(
      id: id,
      name: name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      modifierSelections: modifierSelections ?? this.modifierSelections,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

class CartModifierSelection {
  const CartModifierSelection({
    required this.groupName,
    required this.optionNames,
  });

  final String groupName;
  final List<String> optionNames;
}

List<CartLineItem> _mockCartItems() {
  return const [
    CartLineItem(
      id: 'line-iced-tea',
      name: 'Iced Tea',
      quantity: 2,
      unitPrice: 2.25,
      modifierSelections: [
        CartModifierSelection(groupName: 'Ice', optionNames: ['Less ice']),
        CartModifierSelection(
          groupName: 'Sugar Level',
          optionNames: ['Less sweet'],
        ),
      ],
    ),
    CartLineItem(
      id: 'line-fries',
      name: 'Fries',
      quantity: 1,
      unitPrice: 4.25,
      modifierSelections: [
        CartModifierSelection(groupName: 'Size', optionNames: ['L']),
      ],
    ),
    CartLineItem(
      id: 'line-chicken-rice',
      name: 'Chicken Over Rice',
      quantity: 1,
      unitPrice: 10.00,
    ),
  ];
}
