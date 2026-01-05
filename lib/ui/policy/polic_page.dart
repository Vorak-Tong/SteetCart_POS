import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import 'package:street_cart_pos/ui/core/widgets/product_search_bar.dart';
import 'package:street_cart_pos/ui/policy/widgets/edit_value_dialog.dart';
import 'package:street_cart_pos/ui/policy/widgets/settings_tile.dart';
import 'package:street_cart_pos/ui/policy/viewmodel/policy_viewmodel.dart';

class PolicyPage extends StatefulWidget {
  const PolicyPage({super.key});

  @override
  State<PolicyPage> createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> {
  final PolicyViewModel _viewModel = PolicyViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
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
          ),
          const SizedBox(height: 24),
          Text(
            'Payment Configuration',
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
                  icon: Icons.percent,
                  iconColor: Colors.orange,
                  title: 'Apply VAT at Checkout',
                  subtitle: '${_viewModel.policy.vat}%',
                  onTap: () async {
                    final newValue = await showDialog<String>(
                      context: context,
                      builder: (context) => EditValueDialog(
                        title: 'VAT Percentage',
                        initialValue: _viewModel.policy.vat.toString(),
                        suffix: '%',
                        validator: _viewModel.validateVat,
                      ),
                    );
                    if (newValue != null) {
                      _viewModel.updateVat(newValue);
                    }
                  },
                ),
                Divider(height: 1, indent: 64, color: colorScheme.outlineVariant.withOpacity(0.5)),
                SettingsTile(
                  icon: Icons.currency_exchange,
                  iconColor: Colors.blue,
                  title: 'Currency Exchange Rate',
                  subtitle: '1 USD = ${_viewModel.policy.exchangeRate} KHR',
                  onTap: () async {
                    final newValue = await showDialog<String>(
                      context: context,
                      builder: (context) => EditValueDialog(
                        title: 'Exchange Rate',
                        initialValue: _viewModel.policy.exchangeRate.toString(),
                        suffix: 'KHR',
                        helperText: '1 USD = ? KHR',
                        validator: _viewModel.validateExchangeRate,
                      ),
                    );
                    if (newValue != null) {
                      _viewModel.updateExchangeRate(newValue);
                    }
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
        color: Colors.black.withOpacity(0.1),
        child: const Center(child: CircularProgressIndicator()),
      ),
  ],
);
      },
    );
  }
}
