import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter/material.dart' show DateUtils;
import 'package:street_cart_pos/data/repositories/order_history_repository.dart';
import 'package:street_cart_pos/data/repositories/sale_policy_repository.dart';
import 'package:street_cart_pos/data/repositories/store_profile_repository.dart';
import 'package:street_cart_pos/domain/models/enums.dart';
import 'package:street_cart_pos/domain/models/order.dart';
import 'package:street_cart_pos/domain/models/sale_policy.dart';
import 'package:street_cart_pos/domain/models/store_profile.dart';
import 'package:street_cart_pos/utils/command.dart';

class OrderViewModel extends ChangeNotifier {
  OrderViewModel({
    DateTime? initialDate,
    OrderHistoryRepository? orderHistoryRepository,
    SalePolicyRepository? salePolicyRepository,
    StoreProfileRepository? storeProfileRepository,
  }) : _orderHistoryRepository =
           orderHistoryRepository ?? OrderHistoryRepository(),
       _salePolicyRepository =
           salePolicyRepository ?? SalePolicyRepositoryImpl(),
       _storeProfileRepository =
           storeProfileRepository ?? StoreProfileRepositoryImpl() {
    _selectedDate = DateUtils.dateOnly(initialDate ?? DateTime.now());
    _statusFilter = OrderStatus.inPrep;
    _orders = const [];
    _expandedOrderIds = <String>{};

    loadOrdersCommand = CommandWithParam((_) => _loadOrders());
    _updateOrderStatusCommand = CommandWithParam(_updateOrderStatus);
    loadOrdersCommand.addListener(notifyListeners);
    _updateOrderStatusCommand.addListener(notifyListeners);

    loadOrdersCommand.execute(null);
  }

  final OrderHistoryRepository _orderHistoryRepository;
  final SalePolicyRepository _salePolicyRepository;
  final StoreProfileRepository _storeProfileRepository;

  SalePolicy _policy = const SalePolicy(vat: 0, exchangeRate: 4000);
  StoreProfile _storeProfile = const StoreProfile(
    name: 'My Store',
    phone: '0123456789',
    address: 'st1, Mod District, Mod City',
  );

  int get vatPercent => _policy.vat.round().clamp(0, 100);
  int get exchangeRateKhrPerUsd =>
      _policy.exchangeRate.round().clamp(1, 1000000);
  RoundingMode get roundingMode => _policy.roundingMode;
  StoreProfile get storeProfile => _storeProfile;

  late final CommandWithParam<void, void> loadOrdersCommand;
  late final CommandWithParam<_UpdateOrderStatusRequest, void>
  _updateOrderStatusCommand;

  late DateTime _selectedDate;
  late OrderStatus _statusFilter;
  late List<Order> _orders;
  late Set<String> _expandedOrderIds;
  bool _hasLoadedOnce = false;

  DateTime get selectedDate => _selectedDate;
  OrderStatus get statusFilter => _statusFilter;
  bool get loading => loadOrdersCommand.running;
  bool get updatingStatus => _updateOrderStatusCommand.running;
  bool get hasLoadedOnce => _hasLoadedOnce;

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

  Future<void> refreshFromDb() => loadOrdersCommand.execute(null);

  void setDate(DateTime date) {
    final next = DateUtils.dateOnly(date);
    if (DateUtils.isSameDay(_selectedDate, next)) {
      return;
    }
    _selectedDate = next;
    _expandedOrderIds.clear();
    notifyListeners();
    loadOrdersCommand.execute(null);
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
  }) => _updateOrderStatusCommand.execute(
    _UpdateOrderStatusRequest(orderId: orderId, status: status),
  );

  Future<void> _loadOrders() async {
    _orders = await _orderHistoryRepository.getOrders();
    _policy = await _salePolicyRepository.getSalePolicy();
    _storeProfile = await _storeProfileRepository.getStoreProfile();
    _expandedOrderIds.removeWhere((id) => !_orders.any((o) => o.id == id));
    _hasLoadedOnce = true;
    notifyListeners();
  }

  Future<void> _updateOrderStatus(_UpdateOrderStatusRequest request) async {
    final orderId = request.orderId;
    final status = request.status;

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
      await _orderHistoryRepository.updateOrderStatus(orderId, status);
    } catch (_) {
      await refreshFromDb();
      rethrow;
    }
  }

  @override
  void dispose() {
    loadOrdersCommand.removeListener(notifyListeners);
    _updateOrderStatusCommand.removeListener(notifyListeners);
    super.dispose();
  }
}

class _UpdateOrderStatusRequest {
  const _UpdateOrderStatusRequest({
    required this.orderId,
    required this.status,
  });

  final String orderId;
  final OrderStatus status;
}
