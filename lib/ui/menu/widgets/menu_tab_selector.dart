import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/menu/menu_tab_state.dart';
import 'package:street_cart_pos/ui/menu/widgets/category_page.dart';
import 'package:street_cart_pos/ui/menu/widgets/menu_page.dart';
import 'package:street_cart_pos/ui/menu/widgets/modifier_page.dart';


enum MenuTab { product, category, modifier }

class MenuTabSelector extends StatelessWidget {
  const MenuTabSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: menuTabIndex,
      builder: (context, _) {
        return IndexedStack(
          index: menuTabIndex.value,
          children: const [MenuPage(), CategoryPage(), ModifierPage()],
        );
      },
    );
  }
}
