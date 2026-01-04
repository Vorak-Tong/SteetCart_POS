import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/core/utils/number_format.dart';
import 'package:street_cart_pos/ui/sale/viewmodel/cart_viewmodel.dart';

class CartCheckoutBar extends StatelessWidget {
  const CartCheckoutBar({
    super.key,
    required this.viewModel,
    required this.onClearPaymentInputs,
    this.onCheckout,
  });

  final CartViewModel viewModel;
  final VoidCallback onClearPaymentInputs;
  final VoidCallback? onCheckout;

  Future<void> _confirmClearCart(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel cart?'),
        content: const Text('This will clear all items in the cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      viewModel.clearCart();
      onClearPaymentInputs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        minimum: const EdgeInsets.all(12),
        child: Material(
          elevation: 6,
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Grand total',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      formatUsd(viewModel.grandTotalUsd),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    formatKhr(viewModel.grandTotalKhr),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: viewModel.items.isEmpty
                          ? null
                          : () => _confirmClearCart(context),
                      tooltip: 'Clear cart',
                      icon: const Icon(Icons.delete_outline),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: viewModel.canCheckout
                            ? (onCheckout ?? () {})
                            : null,
                        child: const Text('Checkout'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
