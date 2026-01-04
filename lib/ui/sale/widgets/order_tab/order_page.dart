import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/sale/viewmodel/order_viewmodel.dart';
import 'package:street_cart_pos/ui/sale/widgets/order_tab/order_date_picker_button.dart';
import 'package:street_cart_pos/ui/sale/widgets/order_tab/order_list_view.dart';
import 'package:street_cart_pos/ui/sale/widgets/order_tab/order_status_filter_bar.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late final OrderViewModel _viewModel = OrderViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _viewModel.selectedDate,
      firstDate: DateTime(now.year - 1, now.month, now.day),
      lastDate: DateTime(now.year + 1, now.month, now.day),
    );
    if (picked != null) {
      _viewModel.setDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing orders on:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OrderDatePickerButton(
                    date: _viewModel.selectedDate,
                    onPickDate: () => _pickDate(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OrderStatusFilterBar(
                value: _viewModel.statusFilter,
                onChanged: _viewModel.setStatusFilter,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: OrderListView(
                  orders: _viewModel.filteredOrders,
                  isExpanded: _viewModel.isExpanded,
                  onToggleExpanded: _viewModel.toggleExpanded,
                  onUpdateStatus: (orderId, status) => _viewModel
                      .updateOrderStatus(orderId: orderId, status: status),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
