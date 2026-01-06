import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/core/widgets/navigation/badge_icon.dart';
import 'package:street_cart_pos/ui/sale/utils/cart_badge_state.dart';
import 'package:street_cart_pos/ui/sale/utils/add_to_cart_fly_animation.dart';

enum FeatureTabSet { sale, menu }

class BottomNavGenerator extends StatelessWidget {
  const BottomNavGenerator({
    super.key,
    required this.tabSet,
    required this.currentIndex,
    required this.onTap,
  });

  final FeatureTabSet tabSet;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final items = _itemsFor(tabSet);
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
    );
  }

  List<BottomNavigationBarItem> _itemsFor(FeatureTabSet tabSet) {
    switch (tabSet) {
      case FeatureTabSet.sale:
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale),
            label: 'Sale',
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              key: cartBottomNavIconKey,
              child: ValueListenableBuilder<int>(
                valueListenable: cartItemLineCount,
                builder: (context, count, _) => BadgeIcon(
                  count: count,
                  child: const Icon(Icons.shopping_cart),
                ),
              ),
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Order',
          ),
        ];
      case FeatureTabSet.menu:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Category',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_drink),
            label: 'Modifier',
          ),
        ];
    }
  }
}
