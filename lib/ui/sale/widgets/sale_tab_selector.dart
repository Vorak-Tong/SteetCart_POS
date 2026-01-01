import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/sale/sale_tab_state.dart';
import 'package:street_cart_pos/ui/sale/widgets/cart_page.dart';
import 'package:street_cart_pos/ui/sale/widgets/order_page.dart';
import 'package:street_cart_pos/ui/sale/widgets/sale_page.dart';

enum SaleTab { sale, cart, order }

class SaleTabSelector extends StatelessWidget {
  const SaleTabSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: saleTabIndex,
      builder: (context, index, _) {
        return IndexedStack(
          index: index,
          children: const [SalePage(), CartPage(), OrderPage()],
        );
      },
    );
  }
}
