import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/enums.dart';

Future<OrderStatus?> showOrderStatusEditSheet(
  BuildContext context, {
  required OrderStatus current,
}) {
  return showModalBottomSheet<OrderStatus>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => OrderStatusEditSheet(current: current),
  );
}

class OrderStatusEditSheet extends StatelessWidget {
  const OrderStatusEditSheet({super.key, required this.current});

  final OrderStatus current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final evenBg = Color.alphaBlend(
      theme.colorScheme.onSurface.withValues(alpha: 0.02),
      surface,
    );
    final oddBg = Color.alphaBlend(
      theme.colorScheme.onSurface.withValues(alpha: 0.05),
      surface,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Update status',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ..._editableStatuses.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            return Material(
              color: index.isEven ? evenBg : oddBg,
              borderRadius: BorderRadius.circular(10),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: Text(_statusLabel(status)),
                trailing: status == current
                    ? const Icon(Icons.check, size: 18)
                    : const SizedBox.shrink(),
                onTap: () => Navigator.of(context).pop(status),
              ),
            );
          }),
        ],
      ),
    );
  }
}

const _editableStatuses = <OrderStatus>[
  OrderStatus.inPrep,
  OrderStatus.ready,
  OrderStatus.served,
  OrderStatus.cancel,
];

String _statusLabel(OrderStatus status) {
  switch (status) {
    case OrderStatus.inPrep:
      return 'In prep';
    case OrderStatus.ready:
      return 'Ready';
    case OrderStatus.served:
      return 'Served';
    case OrderStatus.cancel:
      return 'Cancelled';
  }
}
