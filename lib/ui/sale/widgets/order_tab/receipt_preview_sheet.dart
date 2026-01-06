import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/order_model.dart';
import 'package:street_cart_pos/domain/models/enums.dart';
import 'package:street_cart_pos/domain/models/store_profile.dart';
import 'package:street_cart_pos/ui/core/utils/number_format.dart';

Future<void> showReceiptPreviewSheet(
  BuildContext context, {
  required Order order,
  int? displayNumber,
  required int vatPercent,
  required int exchangeRateKhrPerUsd,
  required RoundingMode roundingMode,
  required StoreProfile storeProfile,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => ReceiptPreviewSheet(
      order: order,
      displayNumber: displayNumber,
      vatPercent: vatPercent,
      exchangeRateKhrPerUsd: exchangeRateKhrPerUsd,
      roundingMode: roundingMode,
      storeProfile: storeProfile,
    ),
  );
}

class ReceiptPreviewSheet extends StatelessWidget {
  const ReceiptPreviewSheet({
    super.key,
    required this.order,
    required this.displayNumber,
    required this.vatPercent,
    required this.exchangeRateKhrPerUsd,
    required this.roundingMode,
    required this.storeProfile,
  });

  final Order order;
  final int? displayNumber;
  final int vatPercent;
  final int exchangeRateKhrPerUsd;
  final RoundingMode roundingMode;
  final StoreProfile storeProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final subtotal = order.getTotal();
    final vatRate = (vatPercent.clamp(0, 100)) / 100.0;
    final vat = subtotal * vatRate;
    final totalUsd = subtotal + vat;
    final totalKhr = _toKhr(
      totalUsd,
      exchangeRateKhrPerUsd: exchangeRateKhrPerUsd,
      roundingMode: roundingMode,
    );

    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(order.timeStamp),
      alwaysUse24HourFormat: true,
    );
    final date = MaterialLocalizations.of(
      context,
    ).formatShortDate(order.timeStamp);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Receipt preview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Flexible(
            child: SingleChildScrollView(
              child: Card(
                elevation: 2,
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: DefaultTextStyle(
                    style: theme.textTheme.bodySmall ?? const TextStyle(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            storeProfile.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          storeProfile.phone,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          storeProfile.address,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          displayNumber == null
                              ? 'Order'
                              : 'Order $displayNumber',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'ID: ${order.id}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('$date • $time'),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        for (final item in order.orderProducts) ...[
                          _ReceiptLineItem(item: item),
                          const SizedBox(height: 8),
                        ],
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        _AmountRow(
                          label: 'Subtotal',
                          value: formatUsd(subtotal),
                        ),
                        const SizedBox(height: 4),
                        _AmountRow(
                          label: 'VAT ($vatPercent%)',
                          value: formatUsd(vat),
                        ),
                        const SizedBox(height: 4),
                        _AmountRow(
                          label:
                              'Rate (1 USD = ${formatIntWithThousandsSeparator(exchangeRateKhrPerUsd)} KHR)',
                          value: '',
                        ),
                        const SizedBox(height: 8),
                        _AmountRow(
                          label: 'Total',
                          value: formatUsd(totalUsd),
                          valueStyle: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '(${formatKhr(totalKhr)})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (order.payment != null) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          Text(
                            'Payment',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text('Method: ${order.payment!.type.name}'),
                          Text(
                            'Receive USD: ${formatUsd(order.payment!.recieveAmountUSD)}',
                          ),
                          Text(
                            'Receive KHR: ${formatKhr(order.payment!.recieveAmountKHR)}',
                          ),
                          Text(
                            'Change KHR: ${formatKhr(order.payment!.changeKhr)}',
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: null,
            icon: const Icon(Icons.print_outlined),
            label: const Text('Print (coming soon)'),
          ),
        ],
      ),
    );
  }
}

class _ReceiptLineItem extends StatelessWidget {
  const _ReceiptLineItem({required this.item});

  final OrderProduct item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final name = item.product?.name ?? 'Unknown item';

    final modifierLines = <String>[];
    for (final selection in item.modifierSelections) {
      if (selection.optionNames.isEmpty) continue;
      modifierLines.add(
        '${selection.groupName}: ${selection.optionNames.join(', ')}',
      );
    }

    final note = item.note?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.quantity}×',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatUsd(item.getLineTotal()),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (modifierLines.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 22, top: 2),
            child: Text(
              'no modifiers',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          for (final line in modifierLines)
            Padding(
              padding: const EdgeInsets.only(left: 22, top: 2),
              child: Text(
                line,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        if (note != null && note.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 22, top: 2),
            child: Text(
              'Note: $note',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.label, required this.value, this.valueStyle});

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Text(label)),
        if (value.isNotEmpty)
          Text(value, style: valueStyle ?? theme.textTheme.bodySmall),
      ],
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
