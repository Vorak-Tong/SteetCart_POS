import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:street_cart_pos/domain/models/enums.dart';
import 'package:street_cart_pos/ui/core/utils/number_format.dart';
import 'package:street_cart_pos/ui/sale/viewmodel/cart_viewmodel.dart';

class CartPaymentSection extends StatelessWidget {
  const CartPaymentSection({
    super.key,
    required this.viewModel,
    required this.receivedUsdController,
    required this.receivedKhrController,
    required this.onUsdChanged,
    required this.onKhrChanged,
  });

  final CartViewModel viewModel;
  final TextEditingController receivedUsdController;
  final TextEditingController receivedKhrController;
  final ValueChanged<String> onUsdChanged;
  final ValueChanged<String> onKhrChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final usdActive = receivedUsdController.text.trim().isNotEmpty;
    final khrActive = receivedKhrController.text.trim().isNotEmpty;
    final usdEnabled = !khrActive;
    final khrEnabled = !usdActive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<PaymentMethod>(
          segments: const [
            ButtonSegment(
              value: PaymentMethod.cash,
              label: Text('Cash'),
              icon: Icon(Icons.payments_outlined),
            ),
            ButtonSegment(
              value: PaymentMethod.KHQR,
              label: Text('KHQR'),
              icon: Icon(Icons.qr_code_2_outlined),
            ),
          ],
          selected: {viewModel.paymentMethod},
          onSelectionChanged: (selected) =>
              viewModel.setPaymentMethod(selected.first),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const ValueKey('cart_received_usd'),
                controller: receivedUsdController,
                enabled: usdEnabled,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Receive USD',
                  prefixText: '\$ ',
                  errorText: viewModel.receivedUsdError,
                ),
                onChanged: onUsdChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                key: const ValueKey('cart_received_khr'),
                controller: receivedKhrController,
                enabled: khrEnabled,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Receive KHR',
                  prefixText: 'KHR ',
                  errorText: viewModel.receivedKhrError,
                ),
                onChanged: onKhrChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                'Change',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              viewModel.changeKhr == null
                  ? 'KHR —'
                  : formatKhr(viewModel.changeKhr!),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
