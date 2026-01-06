import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/core/widgets/inline_hint_card.dart';
import 'package:street_cart_pos/ui/sale/utils/sale_tab_state.dart';
import 'package:street_cart_pos/ui/sale/viewmodel/cart_viewmodel.dart';
import 'package:street_cart_pos/ui/sale/widgets/cart_tab/cart_body.dart';
import 'package:street_cart_pos/ui/sale/widgets/cart_tab/cart_checkout_bar.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key, this.viewModel});

  final CartViewModel? viewModel;

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late final CartViewModel _viewModel = widget.viewModel ?? CartViewModel();
  late final TextEditingController _receivedUsdController =
      TextEditingController();
  late final TextEditingController _receivedKhrController =
      TextEditingController();

  bool _suppressPaymentTextEvents = false;

  void _onTabIndexChanged() {
    // Refresh when the Cart tab becomes active.
    if (saleTabIndex.value == 1) {
      _viewModel.refreshFromDb();
    }
  }

  @override
  void initState() {
    super.initState();
    saleTabIndex.addListener(_onTabIndexChanged);
  }

  void _clearPaymentInputs() {
    _suppressPaymentTextEvents = true;
    _receivedUsdController.clear();
    _receivedKhrController.clear();
    _suppressPaymentTextEvents = false;
  }

  void _onUsdChanged(String input) {
    if (_suppressPaymentTextEvents) {
      return;
    }

    _viewModel.setReceivedUsd(input);

    if (input.trim().isNotEmpty &&
        _receivedKhrController.text.trim().isNotEmpty) {
      _suppressPaymentTextEvents = true;
      _receivedKhrController.clear();
      _suppressPaymentTextEvents = false;
      _viewModel.setReceivedKhr('');
    }
  }

  void _onKhrChanged(String input) {
    if (_suppressPaymentTextEvents) {
      return;
    }

    _viewModel.setReceivedKhr(input);

    if (input.trim().isNotEmpty &&
        _receivedUsdController.text.trim().isNotEmpty) {
      _suppressPaymentTextEvents = true;
      _receivedUsdController.clear();
      _suppressPaymentTextEvents = false;
      _viewModel.setReceivedUsd('');
    }
  }

  @override
  void dispose() {
    saleTabIndex.removeListener(_onTabIndexChanged);
    if (widget.viewModel == null) {
      _viewModel.dispose();
    }
    _receivedUsdController.dispose();
    _receivedKhrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        const checkoutBarGap = 120.0;

        if (!_viewModel.hasLoadedOnce) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_viewModel.hasLoadedOnce &&
            !_viewModel.loading &&
            _viewModel.items.isEmpty) {
          _clearPaymentInputs();
          return Padding(
            padding: const EdgeInsets.all(16),
            child: InlineHintCard(
              alignment: Alignment.center,
              message: 'Cart is empty. Add items from Sale to start an order.',
              actionLabel: 'Go to Sale',
              onAction: () => saleTabIndex.value = 0,
            ),
          );
        }

        return Stack(
          children: [
            CartBody(
              viewModel: _viewModel,
              receivedUsdController: _receivedUsdController,
              receivedKhrController: _receivedKhrController,
              onUsdChanged: _onUsdChanged,
              onKhrChanged: _onKhrChanged,
              bottomPadding: checkoutBarGap,
            ),
            const SizedBox(height: 20),
            CartCheckoutBar(
              viewModel: _viewModel,
              onClearPaymentInputs: _clearPaymentInputs,
              onCheckout: () async {
                try {
                  await _viewModel.checkout();
                  _clearPaymentInputs();
                  if (!context.mounted) return;
                  saleTabIndex.value = 2;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Order placed')));
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Checkout failed: $e')),
                  );
                }
              },
            ),
            if (_viewModel.loading && !_viewModel.hasLoadedOnce)
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
