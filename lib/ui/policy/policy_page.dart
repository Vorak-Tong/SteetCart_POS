import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/enums.dart';
import 'package:street_cart_pos/domain/models/product.dart';
import 'package:street_cart_pos/ui/core/widgets/product/product_search_bar.dart';
import 'package:street_cart_pos/ui/policy/widgets/settings_tile.dart';
import 'package:street_cart_pos/ui/policy/widgets/about_store_page.dart';
import 'package:street_cart_pos/ui/policy/widgets/payment_policy_page.dart';
import 'package:street_cart_pos/ui/policy/widgets/printer_settings_page.dart';
import 'package:street_cart_pos/ui/policy/viewmodel/payment_policy_viewmodel.dart';
import 'package:street_cart_pos/ui/policy/viewmodel/printer_settings_viewmodel.dart';

class PolicyPage extends StatefulWidget {
  const PolicyPage({super.key});

  @override
  State<PolicyPage> createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> {
  final PaymentPolicyViewModel _viewModel = PaymentPolicyViewModel();
  final PrinterSettingsViewModel _printerViewModel = PrinterSettingsViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    _printerViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_viewModel, _printerViewModel]),
      builder: (context, _) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final roundingLabel = _roundingModeLabel(
          _viewModel.policy.roundingMode,
        );

        if (_viewModel.loadPolicyCommand.running) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductSearchBar(
                    products: const <Product>[],
                    query: '',
                    onQueryChanged: (_) {},
                    selectedCategoryId: '',
                    hintText: 'Search Policy',
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Store Profile',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        SettingsTile(
                          icon: Icons.storefront_outlined,
                          iconColor: Colors.teal,
                          title: 'About Store',
                          subtitle: 'Store name, contact, address',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AboutStorePage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Payment',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        SettingsTile(
                          icon: Icons.currency_exchange,
                          iconColor: Colors.blue,
                          title: 'Payment',
                          subtitle:
                              'VAT ${_viewModel.policy.vat}% • 1 USD = ${_viewModel.policy.exchangeRate} KHR • $roundingLabel',
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PaymentPolicyPage(),
                              ),
                            );
                            _viewModel.loadPolicyCommand.execute(null);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Devices',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        SettingsTile(
                          icon: Icons.print_outlined,
                          iconColor: Colors.deepPurple,
                          title: 'Printer',
                          subtitle: _printerViewModel.settings.isConfigured
                              ? '${_printerViewModel.settings.deviceName ?? 'Printer'} • ${_printerViewModel.settings.bluetoothMacAddress}'
                              : 'Not configured',
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PrinterSettingsPage(),
                              ),
                            );
                            _printerViewModel.refresh();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_viewModel.updatePolicyCommand.running)
              Container(
                color: Colors.black.withValues(alpha: 0.1),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }
}

String _roundingModeLabel(RoundingMode mode) {
  switch (mode) {
    case RoundingMode.roundUp:
      return 'Round up';
    case RoundingMode.roundDown:
      return 'Round down';
  }
}
