import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/enums.dart';
import 'package:street_cart_pos/domain/models/order_model.dart';
import 'package:street_cart_pos/domain/models/store_profile.dart';
import 'package:street_cart_pos/ui/core/utils/number_format.dart';
import 'package:street_cart_pos/ui/sale/widgets/order_tab/receipt_preview_sheet.dart';
import 'package:street_cart_pos/ui/sale/widgets/order_tab/order_status_edit_sheet.dart';

class OrderListTile extends StatelessWidget {
  const OrderListTile({
    super.key,
    required this.order,
    this.displayNumber,
    required this.vatPercent,
    required this.exchangeRateKhrPerUsd,
    required this.roundingMode,
    required this.storeProfile,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onUpdateStatus,
  });

  final Order order;
  final int? displayNumber;
  final int vatPercent;
  final int exchangeRateKhrPerUsd;
  final RoundingMode roundingMode;
  final StoreProfile storeProfile;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final Future<void> Function(OrderStatus status) onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(order.timeStamp),
      alwaysUse24HourFormat: true,
    );
    final status = order.orderStatus;
    final effectiveVatPercent = order.vatPercentApplied ?? vatPercent;
    final effectiveExchangeRate =
        order.usdToKhrRateApplied ?? exchangeRateKhrPerUsd;
    final effectiveRoundingMode = order.roundingModeApplied ?? roundingMode;

    final vatRate = (effectiveVatPercent.clamp(0, 100)) / 100.0;
    final grandTotalUsd = order.getTotal() * (1 + vatRate);
    final grandTotalKhr = _toKhr(
      grandTotalUsd,
      exchangeRateKhrPerUsd: effectiveExchangeRate,
      roundingMode: effectiveRoundingMode,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                title: Text(
                  displayNumber == null
                      ? _fallbackOrderTitle(order.id)
                      : 'Order $displayNumber',
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$time • ${_orderTypeLabel(order.orderType)}'),
                    Text(
                      'ID: ${order.id}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'VAT ($effectiveVatPercent%) • (1 USD = ${formatIntWithThousandsSeparator(effectiveExchangeRate)} KHR)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 18),
                    Text(
                      formatUsd(grandTotalUsd),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '(${formatKhr(grandTotalKhr)})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 6, 0),
                child: Row(
                  children: [
                    IconButton(
                      key: ValueKey('order_toggle_${order.id}'),
                      tooltip: expanded ? 'Collapse' : 'Expand',
                      onPressed: onToggleExpanded,
                      icon: Icon(
                        expanded ? Icons.expand_less : Icons.expand_more,
                      ),
                    ),
                    const Spacer(),
                    _StatusChip(status: status),
                    const SizedBox(width: 6),
                    IconButton(
                      key: ValueKey('order_edit_status_${order.id}'),
                      tooltip: 'Edit status',
                      onPressed: status == null
                          ? null
                          : () async {
                              final next = await showOrderStatusEditSheet(
                                context,
                                current: status,
                              );
                              if (next != null && next != status) {
                                try {
                                  await onUpdateStatus(next);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Update failed: $e'),
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              ClipRect(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: expanded
                      ? _OrderItems(order: order)
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              tooltip: 'Print',
              onPressed: () => showReceiptPreviewSheet(
                context,
                order: order,
                displayNumber: displayNumber,
                vatPercent: effectiveVatPercent,
                exchangeRateKhrPerUsd: effectiveExchangeRate,
                roundingMode: effectiveRoundingMode,
                storeProfile: storeProfile,
              ),
              icon: const Icon(Icons.print_outlined, size: 18),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            ),
          ),
        ],
      ),
    );
  }
}

int _toKhr(
  double usdAmount, {
  required int exchangeRateKhrPerUsd,
  required RoundingMode roundingMode,
}) {
  final value = usdAmount * exchangeRateKhrPerUsd;
  return switch (roundingMode) {
    RoundingMode.roundUp => value.ceil(),
    RoundingMode.roundDown => value.floor(),
  };
}

class _OrderItems extends StatelessWidget {
  const _OrderItems({required this.order});

  final Order order;

  List<Widget> _buildDetailLines(
    ThemeData theme, {
    required List<OrderModifierSelection> modifierSelections,
    required String? note,
  }) {
    final lines = <Widget>[];
    var hasModifiers = false;

    for (final selection in modifierSelections) {
      if (selection.optionNames.isEmpty) {
        continue;
      }
      hasModifiers = true;
      lines.add(
        Padding(
          padding: const EdgeInsets.only(left: 22, top: 2),
          child: Text(
            '${selection.groupName}: ${selection.optionNames.join(', ')}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    if (!hasModifiers) {
      lines.add(
        Padding(
          padding: const EdgeInsets.only(left: 22, top: 2),
          child: Text(
            'no modifiers',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    final trimmed = note?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      lines.add(
        Padding(
          padding: const EdgeInsets.only(left: 22, top: 2),
          child: Text(
            'Note: $trimmed',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in order.orderProducts)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${item.quantity}×',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.product?.name ?? 'Unknown item',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  ..._buildDetailLines(
                    theme,
                    modifierSelections: item.modifierSelections,
                    note: item.note,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

String _fallbackOrderTitle(String id) {
  final parts = id.split('-');
  final number = parts.isEmpty ? id : parts.last;
  return 'Order $number';
}

String _orderTypeLabel(OrderType type) {
  switch (type) {
    case OrderType.dineIn:
      return 'Dine in';
    case OrderType.takeAway:
      return 'Take away';
    case OrderType.delivery:
      return 'Delivery';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final OrderStatus? status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (bg, fg, label) = _statusStyle(theme.colorScheme, status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

(Color, Color, String) _statusStyle(ColorScheme scheme, OrderStatus? status) {
  if (status == null) {
    return (scheme.surfaceContainerHighest, scheme.onSurfaceVariant, 'Draft');
  }

  switch (status) {
    case OrderStatus.inPrep:
      return (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
        'In prep',
      );
    case OrderStatus.ready:
      return (scheme.tertiaryContainer, scheme.onTertiaryContainer, 'Ready');
    case OrderStatus.served:
      return (scheme.primaryContainer, scheme.onPrimaryContainer, 'Served');
    case OrderStatus.cancel:
      return (scheme.errorContainer, scheme.onErrorContainer, 'Cancelled');
  }
}
