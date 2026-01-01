import 'package:flutter/material.dart';

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
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'Sale'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Order'),
        ];
      case FeatureTabSet.menu:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Category'),
          BottomNavigationBarItem(icon: Icon(Icons.local_drink), label: 'Modifier'),
        ];
    }
  }
}
