import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/enums.dart';

Future<SaleStatus?> showOrderStatusEditSheet(
  BuildContext context, {
  required SaleStatus current,
}) {
  return showModalBottomSheet<SaleStatus>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => OrderStatusEditSheet(current: current),
  );
}

class OrderStatusEditSheet extends StatelessWidget {
  const OrderStatusEditSheet({super.key, required this.current});

  final SaleStatus current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          ..._editableStatuses.map(
            (status) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_statusLabel(status)),
              trailing: status == current
                  ? const Icon(Icons.check, size: 18)
                  : const SizedBox.shrink(),
              onTap: () => Navigator.of(context).pop(status),
            ),
          ),
        ],
      ),
    );
  }
}

const _editableStatuses = <SaleStatus>[
  SaleStatus.inPrep,
  SaleStatus.ready,
  SaleStatus.served,
  SaleStatus.cancelled,
];

String _statusLabel(SaleStatus status) {
  switch (status) {
    case SaleStatus.inPrep:
      return 'In prep';
    case SaleStatus.ready:
      return 'Ready';
    case SaleStatus.served:
      return 'Served';
    case SaleStatus.cancelled:
      return 'Cancelled';
    case SaleStatus.draft:
      return 'Draft';
    case SaleStatus.finalized:
      return 'Finalized';
  }
}
