import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/enums.dart';
import 'package:street_cart_pos/domain/models/order_model.dart';
import 'package:street_cart_pos/ui/sale/widgets/order_tab/order_list_tile.dart';

class OrderListView extends StatelessWidget {
  const OrderListView({
    super.key,
    required this.orders,
    required this.orderNumberById,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.onUpdateStatus,
  });

  final List<Order> orders;
  final Map<String, int> orderNumberById;
  final bool Function(String orderId) isExpanded;
  final void Function(String orderId) onToggleExpanded;
  final void Function(String orderId, OrderStatus status) onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(child: Text('No orders'));
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderListTile(
          order: order,
          displayNumber: orderNumberById[order.id],
          expanded: isExpanded(order.id),
          onToggleExpanded: () => onToggleExpanded(order.id),
          onUpdateStatus: (status) => onUpdateStatus(order.id, status),
        );
      },
    );
  }
}
