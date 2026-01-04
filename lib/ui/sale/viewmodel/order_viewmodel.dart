import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter/material.dart' show DateUtils;
import 'package:street_cart_pos/domain/models/enums.dart';
import 'package:street_cart_pos/domain/models/order_model.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';

class OrderViewModel extends ChangeNotifier {
  OrderViewModel({DateTime? initialDate}) {
    _selectedDate = DateUtils.dateOnly(initialDate ?? DateTime.now());
    _statusFilter = SaleStatus.inPrep;
    _orders = _mockOrders();
    _expandedOrderIds = <String>{};
  }

  late DateTime _selectedDate;
  late SaleStatus _statusFilter;
  late List<Order> _orders;
  late Set<String> _expandedOrderIds;

  DateTime get selectedDate => _selectedDate;
  SaleStatus get statusFilter => _statusFilter;

  List<SaleStatus> get availableStatuses => const [
    SaleStatus.inPrep,
    SaleStatus.ready,
    SaleStatus.served,
    SaleStatus.cancelled,
  ];

  List<Order> get filteredOrders {
    return _orders
        .where((o) => DateUtils.isSameDay(o.timeStamp, _selectedDate))
        .where((o) => o.status == _statusFilter)
        .toList()
      ..sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
  }

  bool isExpanded(String orderId) => _expandedOrderIds.contains(orderId);

  void toggleExpanded(String orderId) {
    if (_expandedOrderIds.contains(orderId)) {
      _expandedOrderIds.remove(orderId);
    } else {
      _expandedOrderIds.add(orderId);
    }
    notifyListeners();
  }

  void setDate(DateTime date) {
    final next = DateUtils.dateOnly(date);
    if (DateUtils.isSameDay(_selectedDate, next)) {
      return;
    }
    _selectedDate = next;
    _expandedOrderIds.clear();
    notifyListeners();
  }

  void setStatusFilter(SaleStatus status) {
    if (_statusFilter == status) {
      return;
    }
    _statusFilter = status;
    _expandedOrderIds.clear();
    notifyListeners();
  }

  void updateOrderStatus({
    required String orderId,
    required SaleStatus status,
  }) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) {
      return;
    }
    if (_orders[index].status == status) {
      return;
    }
    _orders[index].updateStatus(status);
    notifyListeners();
  }
}

List<Order> _mockOrders() {
  final today = DateTime.now();
  final yesterday = today.subtract(const Duration(days: 1));

  final icedTea = Product(id: 'p-iced-tea', name: 'Iced Tea', basePrice: 2.25);
  final fries = Product(id: 'p-fries', name: 'Fries', basePrice: 4.25);
  final chicken = Product(
    id: 'p-chicken-rice',
    name: 'Chicken Over Rice',
    basePrice: 10.00,
  );

  DateTime at(DateTime day, int hour, int minute) {
    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  return [
    Order(
      id: 'order-1001',
      timeStamp: at(today, 10, 12),
      orderType: OrderType.dineIn,
      paymentType: PaymentMethod.cash,
      status: SaleStatus.inPrep,
      orderProducts: [
        OrderProduct(
          quantity: 2,
          product: icedTea,
          modifierSelections: const [
            OrderModifierSelection(
              groupName: 'Sugar Level',
              optionNames: ['Less sweet'],
            ),
            OrderModifierSelection(groupName: 'Ice', optionNames: ['Less ice']),
          ],
          note: 'No straw',
        ),
        OrderProduct(
          quantity: 1,
          product: fries,
          modifierSelections: const [
            OrderModifierSelection(groupName: 'Size', optionNames: ['L']),
          ],
        ),
      ],
    ),
    Order(
      id: 'order-1002',
      timeStamp: at(today, 10, 25),
      orderType: OrderType.takeAway,
      paymentType: PaymentMethod.cash,
      status: SaleStatus.inPrep,
      orderProducts: [
        OrderProduct(quantity: 1, product: chicken, note: 'Extra spicy'),
      ],
    ),
    Order(
      id: 'order-1003',
      timeStamp: at(today, 9, 50),
      orderType: OrderType.delivery,
      paymentType: PaymentMethod.KHQR,
      status: SaleStatus.ready,
      orderProducts: [
        OrderProduct(quantity: 1, product: icedTea),
        OrderProduct(quantity: 1, product: chicken),
      ],
    ),
    Order(
      id: 'order-1004',
      timeStamp: at(today, 9, 10),
      orderType: OrderType.dineIn,
      paymentType: PaymentMethod.cash,
      status: SaleStatus.served,
      orderProducts: [OrderProduct(quantity: 1, product: fries)],
    ),
    Order(
      id: 'order-1005',
      timeStamp: at(today, 8, 45),
      orderType: OrderType.takeAway,
      paymentType: PaymentMethod.cash,
      status: SaleStatus.cancelled,
      orderProducts: [OrderProduct(quantity: 2, product: chicken)],
    ),
    Order(
      id: 'order-0901',
      timeStamp: at(yesterday, 11, 5),
      orderType: OrderType.dineIn,
      paymentType: PaymentMethod.cash,
      status: SaleStatus.inPrep,
      orderProducts: [OrderProduct(quantity: 1, product: icedTea)],
    ),
  ];
}
