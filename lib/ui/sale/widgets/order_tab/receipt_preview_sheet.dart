import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/order_model.dart';
import 'package:street_cart_pos/domain/models/enums.dart';
import 'package:street_cart_pos/domain/models/store_profile.dart';
import 'package:street_cart_pos/ui/core/printing/bluetooth_printer_service.dart';
import 'package:street_cart_pos/ui/core/utils/number_format.dart';
import 'package:street_cart_pos/ui/policy/widgets/printer_settings_page.dart';
import 'package:street_cart_pos/ui/core/printing/receipt_escpos_builder.dart';

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
    return _ReceiptPreviewBody(
      order: order,
      displayNumber: displayNumber,
      vatPercent: vatPercent,
      exchangeRateKhrPerUsd: exchangeRateKhrPerUsd,
      roundingMode: roundingMode,
      storeProfile: storeProfile,
    );
  }
}

class _ReceiptPreviewBody extends StatefulWidget {
  const _ReceiptPreviewBody({
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
  State<_ReceiptPreviewBody> createState() => _ReceiptPreviewBodyState();
}

class _ReceiptPreviewBodyState extends State<_ReceiptPreviewBody> {
  final BluetoothPrinterService _printerService = BluetoothPrinterService();
  final ReceiptEscPosBuilder _builder = ReceiptEscPosBuilder();

  bool _printing = false;

  Future<void> _print() async {
    if (_printing) return;
    setState(() => _printing = true);

    try {
      final settings = await _printerService.getSettings();
      if (!settings.isConfigured) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a printer first.')),
        );
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PrinterSettingsPage()));
        return;
      }

      if (!mounted) return;
      final time = MaterialLocalizations.of(context).formatTimeOfDay(
        TimeOfDay.fromDateTime(widget.order.timeStamp),
        alwaysUse24HourFormat: true,
      );
      final date = MaterialLocalizations.of(
        context,
      ).formatShortDate(widget.order.timeStamp);

      final payload = _builder.build(
        storeProfile: widget.storeProfile,
        order: widget.order,
        printerSettings: settings,
        displayNumber: widget.displayNumber,
        vatPercent: widget.vatPercent,
        exchangeRateKhrPerUsd: widget.exchangeRateKhrPerUsd,
        roundingMode: widget.roundingMode,
        formattedDate: date,
        formattedTime: time,
      );

      await _printerService.printBytes(payload);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Print sent.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Print failed: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final subtotal = widget.order.getTotal();
    final vatRate = (widget.vatPercent.clamp(0, 100)) / 100.0;
    final vat = subtotal * vatRate;
    final totalUsd = subtotal + vat;
    final totalKhr = _toKhr(
      totalUsd,
      exchangeRateKhrPerUsd: widget.exchangeRateKhrPerUsd,
      roundingMode: widget.roundingMode,
    );

    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(widget.order.timeStamp),
      alwaysUse24HourFormat: true,
    );
    final date = MaterialLocalizations.of(
      context,
    ).formatShortDate(widget.order.timeStamp);

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
                            widget.storeProfile.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.storeProfile.phone,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          widget.storeProfile.address,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.displayNumber == null
                              ? 'Order'
                              : 'Order ${widget.displayNumber}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'ID: ${widget.order.id}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('$date • $time'),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        for (final item in widget.order.orderProducts) ...[
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
                          label: 'VAT (${widget.vatPercent}%)',
                          value: formatUsd(vat),
                        ),
                        const SizedBox(height: 4),
                        _AmountRow(
                          label:
                              'Rate (1 USD = ${formatIntWithThousandsSeparator(widget.exchangeRateKhrPerUsd)} KHR)',
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
                        if (widget.order.payment != null) ...[
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
                          Text('Method: ${widget.order.payment!.type.name}'),
                          Text(
                            'Receive USD: ${formatUsd(widget.order.payment!.recieveAmountUSD)}',
                          ),
                          Text(
                            'Receive KHR: ${formatKhr(widget.order.payment!.recieveAmountKHR)}',
                          ),
                          Text(
                            'Change KHR: ${formatKhr(widget.order.payment!.changeKhr)}',
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
            onPressed: _printing ? null : _print,
            icon: const Icon(Icons.print_outlined),
            label: Text(_printing ? 'Printing...' : 'Print'),
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
