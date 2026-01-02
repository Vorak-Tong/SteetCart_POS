import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import 'package:street_cart_pos/ui/core/widgets/add_new_button.dart';
import 'package:street_cart_pos/ui/core/widgets/category_filter_chips.dart';
import 'package:street_cart_pos/ui/core/widgets/product_search_bar.dart';
import 'package:street_cart_pos/ui/menu/widgets/menu_item_card.dart';
import 'package:street_cart_pos/ui/menu/widgets/product_form_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mockProducts = _getMockProducts();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Search Bar + Add New Button
          Row(
            children: [
              Expanded(
                child: ProductSearchBar(
                  products: const [], // Static for now
                  query: '',
                  onQueryChanged: (_) {},
                  selectedCategoryId: '__all__',
                ),
              ),
              const SizedBox(width: 12),
              AddNewButton(onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductFormPage(isEditing: false),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),
          
          // Category Filter
          CategoryFilterChips(
            categories: const [], // Static for now
            selectedCategoryId: '__all__',
            onCategorySelected: (_) {},
          ),
          
          const SizedBox(height: 12),

          // Product List
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: mockProducts
                    .map((product) => MenuItemCard(product: product))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Product> _getMockProducts() {
    return [
      Product(
        name: 'Iced Latte',
        basePrice: 2.50,
        category: Category(name: 'Coffee'),
        modifierGroups: [
          ModifierGroup(name: 'Sugar'),
          ModifierGroup(name: 'Size'),
        ],
      ),
      Product(
        name: 'Cappuccino',
        basePrice: 3.00,
        category: Category(name: 'Coffee'),
      ),
      Product(
        name: 'Green Tea Latte',
        basePrice: 3.50,
        category: Category(name: 'Matcha'),
        modifierGroups: [ModifierGroup(name: 'Toppings')],
      ),
    ];
  }
}
