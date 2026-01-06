import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/sale/utils/sale_tab_state.dart';
import 'package:street_cart_pos/ui/sale/widgets/cart_tab/cart_page.dart';
import 'package:street_cart_pos/ui/sale/widgets/order_tab/order_page.dart';
import 'package:street_cart_pos/ui/sale/widgets/sale_tab/sale_page.dart';

enum SaleTab { sale, cart, order }

class SaleTabSelector extends StatelessWidget {
  const SaleTabSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: saleTabIndex,
      builder: (context, _) {
        return IndexedStack(
          index: saleTabIndex.value,
          children: const [SalePage(), CartPage(), OrderPage()],
        );
      },
    );
  }
}
