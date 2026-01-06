import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import 'package:street_cart_pos/domain/models/enums.dart';
import 'package:street_cart_pos/ui/core/widgets/product_search_bar.dart';
import 'package:street_cart_pos/ui/policy/widgets/settings_tile.dart';
import 'package:street_cart_pos/ui/policy/widgets/about_store_page.dart';
import 'package:street_cart_pos/ui/policy/widgets/payment_policy_page.dart';
import 'package:street_cart_pos/ui/policy/viewmodel/payment_policy_viewmodel.dart';

class PolicyPage extends StatefulWidget {
  const PolicyPage({super.key});

  @override
  State<PolicyPage> createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> {
  final PaymentPolicyViewModel _viewModel = PaymentPolicyViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final roundingLabel = _roundingModeLabel(_viewModel.policy.roundingMode);

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
