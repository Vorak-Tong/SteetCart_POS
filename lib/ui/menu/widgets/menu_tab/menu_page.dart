import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/category.dart';
import 'package:street_cart_pos/domain/models/product.dart';
import 'package:street_cart_pos/ui/core/widgets/add_new_button.dart';
import 'package:street_cart_pos/ui/core/widgets/category_filter_chips.dart';
import 'package:street_cart_pos/ui/core/widgets/product_search_bar.dart';
import 'package:street_cart_pos/ui/core/widgets/swipe_action_background.dart';
import 'package:street_cart_pos/ui/menu/widgets/menu_tab/menu_item_card.dart';
import 'package:street_cart_pos/ui/menu/widgets/menu_tab/product_detail_page.dart';
import 'package:street_cart_pos/ui/menu/widgets/menu_tab/product_form_page.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/menu_viewmodel.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key, this.initialCategories, this.initialProducts});

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
        if (_viewModel.loading && !_viewModel.hasLoadedOnce) {
          return const Center(child: CircularProgressIndicator());
        }

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
                      uncategorizedCategoryId:
                          MenuViewModel.uncategorizedCategoryId,
                      archivedCategoryId: MenuViewModel.archivedCategoryId,
                    ),
                  ),
                  const SizedBox(width: 12),
                  AddNewButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductFormPage(
                            isEditing: false,
                            categories: _viewModel.categories,
                            availableModifiers: _viewModel.modifierGroups,
                            onSave: _viewModel.addProduct,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Category Filter
              CategoryFilterChips(
                categories: _viewModel.categories,
                selectedCategoryId: _viewModel.selectedCategoryId,
                onCategorySelected: _viewModel.setSelectedCategoryId,
                allCategoryId: MenuViewModel.allCategoryId,
                trailingChips: const [
                  CategoryChipItem(
                    id: MenuViewModel.uncategorizedCategoryId,
                    label: 'Uncategorized',
                  ),
                  CategoryChipItem(
                    id: MenuViewModel.archivedCategoryId,
                    label: 'Archived',
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Product List
              Expanded(
                child: ListView.separated(
                  itemCount: _viewModel.filteredProducts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = _viewModel.filteredProducts[index];
                    final canArchive = product.isActive;
                    final leftLabel = canArchive ? 'Archive' : 'Unarchive';
                    final leftIcon = canArchive
                        ? Icons.archive_outlined
                        : Icons.unarchive_outlined;
                    return Dismissible(
                      key: ValueKey(product.id),
                      direction: DismissDirection.horizontal,
                      background: SwipeActionBackground(
                        alignment: Alignment.centerLeft,
                        backgroundColor: const Color(0xFFE9F7EC),
                        borderRadius: 10,
                        icon: leftIcon,
                        iconColor: const Color(0xFF2E7D32),
                        label: leftLabel,
                      ),
                      secondaryBackground: const SwipeActionBackground(
                        alignment: Alignment.centerRight,
                        backgroundColor: Color(0xFFFFEBEB),
                        borderRadius: 10,
                        icon: Icons.delete_outline,
                        iconColor: Colors.red,
                        label: 'Delete',
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd &&
                            product.isActive) {
                          return await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Archive product?'),
                                  content: const Text(
                                    'This will hide the product from active lists. You can restore it later from Archived.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Archive'),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;
                        }
                        if (direction == DismissDirection.endToStart) {
                          return await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete product?'),
                                  content: const Text(
                                    'This will permanently delete the product. Existing sales will keep a snapshot of the product name/price.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;
                        }
                        return true;
                      },
                      onDismissed: (direction) async {
                        try {
                          if (direction == DismissDirection.startToEnd) {
                            if (product.isActive) {
                              await _viewModel.archiveProduct(product);
                            } else {
                              await _viewModel.unarchiveProduct(product);
                            }
                          } else if (direction == DismissDirection.endToStart) {
                            await _viewModel.deleteProduct(product);
                          }
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Action failed: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: MenuItemCard(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(
                                product: product,
                                categories: _viewModel.categories,
                                availableModifiers: _viewModel.modifierGroups,
                                onUpdate: _viewModel.updateProduct,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
