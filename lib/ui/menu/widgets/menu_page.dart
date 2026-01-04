import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import 'package:street_cart_pos/ui/core/widgets/add_new_button.dart';
import 'package:street_cart_pos/ui/core/widgets/category_filter_chips.dart';
import 'package:street_cart_pos/ui/core/widgets/product_search_bar.dart';
import 'package:street_cart_pos/ui/menu/widgets/menu_item_card.dart';
import 'package:street_cart_pos/ui/menu/widgets/product_detail_page.dart';
import 'package:street_cart_pos/ui/menu/widgets/product_form_page.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/menu_viewmodel.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({
    super.key,
    this.initialCategories,
    this.initialProducts,
  });

  final List<Category>? initialCategories;
  final List<Product>? initialProducts;

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late final MenuViewModel _viewModel = MenuViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
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
                      products: _viewModel.products,
                      query: _viewModel.searchQuery,
                      onQueryChanged: _viewModel.setSearchQuery,
                      selectedCategoryId: _viewModel.selectedCategoryId,
                      allCategoryId: MenuViewModel.allCategoryId,
                    ),
                  ),
                  const SizedBox(width: 12),
                  AddNewButton(onPressed: () {
                    if (_viewModel.categories.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please create a Category first.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (_viewModel.modifierGroups.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please create a Modifier Group first.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductFormPage(
                          isEditing: false,
                          categories: _viewModel.categories,
                          availableModifiers: _viewModel.modifierGroups,
                          onSave: (name, description, price, categoryName, modifiers) async {
                            final category = _viewModel.categories.firstWhere(
                              (c) => c.name == categoryName,
                            );

                            await _viewModel.addProduct(Product(
                              name: name,
                              description: description,
                              basePrice: price,
                              category: category,
                              modifierGroups: modifiers,
                            ));
                          },
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 12),

              // Category Filter
              CategoryFilterChips(
                categories: _viewModel.categories,
                selectedCategoryId: _viewModel.selectedCategoryId,
                onCategorySelected: _viewModel.setSelectedCategoryId,
                allCategoryId: MenuViewModel.allCategoryId,
              ),

              const SizedBox(height: 12),

              // Product List
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _viewModel.filteredProducts
                        .map((product) => MenuItemCard(
                              product: product,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductDetailPage(product: product),
                                  ),
                                );
                              },
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
