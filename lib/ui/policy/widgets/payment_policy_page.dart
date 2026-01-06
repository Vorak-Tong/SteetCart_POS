import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:street_cart_pos/domain/models/enums.dart';
import 'package:street_cart_pos/domain/models/sale_policy.dart';
import 'package:street_cart_pos/ui/policy/viewmodel/payment_policy_viewmodel.dart';

class PaymentPolicyPage extends StatefulWidget {
  const PaymentPolicyPage({super.key});

  @override
  State<PaymentPolicyPage> createState() => _PaymentPolicyPageState();
}

class _PaymentPolicyPageState extends State<PaymentPolicyPage> {
  final PaymentPolicyViewModel _viewModel = PaymentPolicyViewModel();

  final _vatController = TextEditingController();
  final _rateController = TextEditingController();

  bool _editing = false;
  RoundingMode _roundingMode = RoundingMode.roundUp;

  @override
  void dispose() {
    _viewModel.dispose();
    _vatController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _syncControllers(SalePolicy policy) {
    if (_editing) return;
    _vatController.text = policy.vat.toString();
    _rateController.text = policy.exchangeRate.toString();
    _roundingMode = policy.roundingMode;
  }

  bool get _formValid {
    return _viewModel.validateVat(_vatController.text.trim()) == null &&
        _viewModel.validateExchangeRate(_rateController.text.trim()) == null;
  }

  Future<void> _startEditing() async {
    final policy = _viewModel.policy;
    setState(() {
      _editing = true;
      _vatController.text = policy.vat.toString();
      _rateController.text = policy.exchangeRate.toString();
      _roundingMode = policy.roundingMode;
    });
  }

  void _cancelEditing() {
    setState(() => _editing = false);
    _syncControllers(_viewModel.policy);
  }

  Future<void> _save() async {
    if (!_editing) return;
    if (!_formValid || _viewModel.updatePolicyCommand.running) return;

    final vat = double.tryParse(_vatController.text.trim());
    final rate = double.tryParse(_rateController.text.trim());
    if (vat == null || rate == null) return;

    try {
      await _viewModel.updatePolicyCommand.execute(
        _viewModel.policy.copyWith(
          vat: vat,
          exchangeRate: rate,
          roundingMode: _roundingMode,
        ),
      );
      if (!mounted) return;
      setState(() => _editing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Payment settings updated')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final theme = Theme.of(context);
        final policy = _viewModel.policy;
        _syncControllers(policy);

        final saving = _viewModel.updatePolicyCommand.running;
        final loading = _viewModel.loadPolicyCommand.running;

        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: const Text('Payment'),
                actions: [
                  if (_editing)
                    TextButton(
                      onPressed: saving ? null : _cancelEditing,
                      child: const Text('Cancel'),
                    )
                  else
                    IconButton(
                      tooltip: 'Edit',
                      onPressed: loading ? null : _startEditing,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  if (_editing)
                    TextButton(
                      onPressed: !_formValid || saving ? null : _save,
                      child: const Text('Save'),
                    ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment configuration',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _vatController,
                              readOnly: !_editing,
                              showCursor: _editing,
                              maxLength: 6,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                const _DecimalTextInputFormatter(
                                  decimalRange: 2,
                                ),
                              ],
                              decoration: InputDecoration(
                                labelText: 'VAT (%)',
                                helperText: '0–100',
                                errorText: _editing
                                    ? _viewModel.validateVat(
                                        _vatController.text.trim(),
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onChanged: _editing
                                  ? (_) => setState(() {})
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _rateController,
                              readOnly: !_editing,
                              showCursor: _editing,
                              maxLength: 10,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                const _DecimalTextInputFormatter(
                                  decimalRange: 2,
                                ),
                              ],
                              decoration: InputDecoration(
                                labelText: 'USD → KHR rate',
                                helperText: '1 USD = ? KHR',
                                errorText: _editing
                                    ? _viewModel.validateExchangeRate(
                                        _rateController.text.trim(),
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onChanged: _editing
                                  ? (_) => setState(() {})
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            DropdownMenu<RoundingMode>(
                              key: ValueKey(_roundingMode),
                              initialSelection: _roundingMode,
                              enabled: _editing,
                              onSelected: (value) {
                                if (value == null) return;
                                setState(() => _roundingMode = value);
                              },
                              label: const Text('Rounding mode'),
                              inputDecorationTheme: InputDecorationTheme(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              dropdownMenuEntries: const [
                                DropdownMenuEntry(
                                  value: RoundingMode.roundUp,
                                  label: 'Round up',
                                ),
                                DropdownMenuEntry(
                                  value: RoundingMode.roundDown,
                                  label: 'Round down',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (saving || loading)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.08),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DecimalTextInputFormatter extends TextInputFormatter {
  const _DecimalTextInputFormatter({required this.decimalRange});

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) {
      return newValue;
    }

    var dotCount = 0;
    for (final codeUnit in text.codeUnits) {
      if (codeUnit == 0x2E) {
        dotCount += 1;
        if (dotCount > 1) return oldValue;
        continue;
      }
      final isDigit = codeUnit >= 0x30 && codeUnit <= 0x39;
      if (!isDigit) return oldValue;
    }

    final dotIndex = text.indexOf('.');
    if (dotIndex >= 0) {
      final fraction = text.substring(dotIndex + 1);
      if (fraction.length > decimalRange) return oldValue;
    }

    return newValue;
  }
}
