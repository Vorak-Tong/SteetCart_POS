import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/sale/viewmodel/cart_viewmodel.dart';
import 'package:street_cart_pos/ui/sale/widgets/cart_tab/cart_body.dart';
import 'package:street_cart_pos/ui/sale/widgets/cart_tab/cart_checkout_bar.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late final CartViewModel _viewModel = CartViewModel();
  late final TextEditingController _receivedUsdController =
      TextEditingController();
  late final TextEditingController _receivedKhrController =
      TextEditingController();

  bool _suppressPaymentTextEvents = false;

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
    _viewModel.dispose();
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
            const SizedBox(height: 20,),
            CartCheckoutBar(
              viewModel: _viewModel,
              onClearPaymentInputs: _clearPaymentInputs,
            ),
          ],
        );
      },
    );
  }
}
