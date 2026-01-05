import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter/material.dart' show DateUtils;
import 'package:street_cart_pos/data/repositories/order_repository.dart';
import 'package:street_cart_pos/domain/models/enums.dart';
import 'package:street_cart_pos/domain/models/order_model.dart';

class OrderViewModel extends ChangeNotifier {
  OrderViewModel({DateTime? initialDate, OrderRepository? orderRepository})
    : _orderRepository = orderRepository ?? OrderRepository() {
    _selectedDate = DateUtils.dateOnly(initialDate ?? DateTime.now());
    _statusFilter = OrderStatus.inPrep;
    _orders = const [];
    _expandedOrderIds = <String>{};
    refreshFromDb();
  }

  final OrderRepository _orderRepository;

  late DateTime _selectedDate;
  late OrderStatus _statusFilter;
  late List<Order> _orders;
  late Set<String> _expandedOrderIds;
  bool _loading = false;

  DateTime get selectedDate => _selectedDate;
  OrderStatus get statusFilter => _statusFilter;
  bool get loading => _loading;

  List<OrderStatus> get availableStatuses => const [
    OrderStatus.inPrep,
    OrderStatus.ready,
    OrderStatus.served,
    OrderStatus.cancel,
  ];

  Map<String, int> get orderNumberByIdForSelectedDate {
    final allOnDay =
        _orders
            .where((o) => o.cartStatus == CartStatus.finalized)
            .where((o) => o.orderStatus != null)
            .where((o) => DateUtils.isSameDay(o.timeStamp, _selectedDate))
            .toList()
          ..sort((a, b) => a.timeStamp.compareTo(b.timeStamp));

    return {for (final entry in allOnDay.indexed) entry.$2.id: entry.$1 + 1};
  }

  List<Order> get filteredOrders {
    return _orders
        .where((o) => o.cartStatus == CartStatus.finalized)
        .where((o) => o.orderStatus != null)
        .where((o) => DateUtils.isSameDay(o.timeStamp, _selectedDate))
        .where((o) => o.orderStatus == _statusFilter)
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

  Future<void> refreshFromDb() async {
    if (_loading) return;
    _loading = true;
    notifyListeners();

    try {
      _orders = await _orderRepository.getOrders();
      _expandedOrderIds.removeWhere((id) => !_orders.any((o) => o.id == id));
    } finally {
      _loading = false;
      notifyListeners();
    }
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

  void setStatusFilter(OrderStatus status) {
    if (_statusFilter == status) {
      return;
    }
    _statusFilter = status;
    _expandedOrderIds.clear();
    notifyListeners();
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  }) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) {
      return;
    }

    final current = _orders[index];
    if (current.orderStatus == status) {
      return;
    }

    current.updateOrderStatus(status);
    notifyListeners();

    try {
      await _orderRepository.updateOrderMeta(
        orderId,
        cartStatus: CartStatus.finalized,
        orderStatus: status,
      );
    } catch (_) {
      await refreshFromDb();
      rethrow;
    }
  }
}
