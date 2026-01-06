import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/core/widgets/feedback/swipe_action_background.dart';
import 'package:street_cart_pos/ui/sale/viewmodel/cart_viewmodel.dart';
import 'package:street_cart_pos/ui/sale/widgets/cart_tab/cart_line_item_tile.dart';
import 'package:street_cart_pos/ui/sale/widgets/cart_tab/cart_order_type_section.dart';
import 'package:street_cart_pos/ui/sale/widgets/cart_tab/cart_payment_section.dart';
import 'package:street_cart_pos/ui/sale/widgets/cart_tab/cart_totals_summary.dart';

class CartBody extends StatelessWidget {
  const CartBody({
    super.key,
    required this.viewModel,
    required this.receivedUsdController,
    required this.receivedKhrController,
    required this.onUsdChanged,
    required this.onKhrChanged,
    this.bottomPadding = 0,
  });

  final CartViewModel viewModel;
  final TextEditingController receivedUsdController;
  final TextEditingController receivedKhrController;
  final ValueChanged<String> onUsdChanged;
  final ValueChanged<String> onKhrChanged;
  final double bottomPadding;

  Future<bool> _confirmDeleteLine(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove item?'),
        content: const Text('This will remove the item from the cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 12, 12, bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
              children: [
                CartOrderTypeSection(
                  value: viewModel.orderType,
                  onChanged: viewModel.setOrderType,
                ),
                const SizedBox(height: 16),
                Text(
                  'Cart Items',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                for (final entry in viewModel.items.indexed) ...[
                  Dismissible(
                    key: ValueKey(entry.$2.id),
                    direction:
                        (viewModel.loading ||
                            viewModel.checkingOut ||
                            viewModel.clearingCart)
                        ? DismissDirection.none
                        : DismissDirection.endToStart,
                    background: const SizedBox.shrink(),
                    secondaryBackground: const SwipeActionBackground(
                      alignment: Alignment.centerRight,
                      backgroundColor: Color(0xFFFFEBEB),
                      borderRadius: 14,
                      icon: Icons.delete_outline,
                      iconColor: Colors.red,
                      label: 'Remove',
                    ),
                    confirmDismiss: (_) => _confirmDeleteLine(context),
                    onDismissed: (_) => viewModel.removeItemLine(entry.$2.id),
                    child: CartLineItemTile(
                      item: entry.$2,
                      onDecrement: entry.$2.quantity <= 1
                          ? null
                          : () {
                              viewModel.decrementItemQuantity(entry.$2.id);
                            },
                      onIncrement: () {
                        viewModel.incrementItemQuantity(entry.$2.id);
                      },
                    ),
                  ),
                  if (entry.$1 != viewModel.items.length - 1)
                    const SizedBox(height: 10),
                ],
                const SizedBox(height: 12),
                CartTotalsSummary(viewModel: viewModel),
                const SizedBox(height: 16),
                CartPaymentSection(
                  viewModel: viewModel,
                  receivedUsdController: receivedUsdController,
                  receivedKhrController: receivedKhrController,
                  onUsdChanged: onUsdChanged,
                  onKhrChanged: onKhrChanged,
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
