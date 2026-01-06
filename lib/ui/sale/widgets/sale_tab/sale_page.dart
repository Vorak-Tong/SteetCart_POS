import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/core/widgets/category_filter_chips.dart';
import 'package:street_cart_pos/ui/core/widgets/product_grid.dart';
import 'package:street_cart_pos/ui/core/widgets/product_search_bar.dart';
import 'package:street_cart_pos/ui/sale/widgets/sale_tab/product_selection_sheet.dart';
import 'package:street_cart_pos/ui/sale/viewmodel/sale_viewmodel.dart';

class SalePage extends StatefulWidget {
  const SalePage({super.key, this.viewModel});

  final SaleViewModel? viewModel;

  @override
  State<SalePage> createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  late final SaleViewModel _viewModel = widget.viewModel ?? SaleViewModel();

  @override
  void dispose() {
    if (widget.viewModel == null) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        if (_viewModel.loading && _viewModel.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              ProductSearchBar(
                products: _viewModel.products,
                query: _viewModel.searchQuery,
                selectedCategoryId: _viewModel.selectedCategoryId,
                allCategoryId: SaleViewModel.allCategoryId,
                uncategorizedCategoryId: SaleViewModel.uncategorizedCategoryId,
                onQueryChanged: _viewModel.setSearchQuery,
              ),
              const SizedBox(height: 12),
              CategoryFilterChips(
                categories: _viewModel.categories,
                selectedCategoryId: _viewModel.selectedCategoryId,
                allCategoryId: SaleViewModel.allCategoryId,
                onCategorySelected: _viewModel.setSelectedCategoryId,
                trailingChips: [
                  if (_viewModel.hasUncategorizedProducts)
                    const CategoryChipItem(
                      id: SaleViewModel.uncategorizedCategoryId,
                      label: 'Uncategorized',
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ProductGrid(
                  products: _viewModel.filteredProducts,
                  onProductTap: (product) =>
                      showProductSelectionSheet(context, product: product),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
