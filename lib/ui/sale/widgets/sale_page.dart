import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/core/widgets/category_filter_chips.dart';
import 'package:street_cart_pos/ui/core/widgets/product_grid.dart';
import 'package:street_cart_pos/ui/core/widgets/product_search_bar.dart';
import 'package:street_cart_pos/ui/sale/viewmodel/sale_viewmodel.dart';

class SalePage extends StatefulWidget {
  const SalePage({super.key});

  @override
  State<SalePage> createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  late final SaleViewModel _viewModel = SaleViewModel();

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
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              ProductSearchBar(
                products: _viewModel.products,
                query: _viewModel.searchQuery,
                selectedCategoryId: _viewModel.selectedCategoryId,
                allCategoryId: SaleViewModel.allCategoryId,
                onQueryChanged: _viewModel.setSearchQuery,
              ),
              const SizedBox(height: 12),
              CategoryFilterChips(
                categories: _viewModel.categories,
                selectedCategoryId: _viewModel.selectedCategoryId,
                allCategoryId: SaleViewModel.allCategoryId,
                onCategorySelected: _viewModel.setSelectedCategoryId,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ProductGrid(products: _viewModel.filteredProducts),
              ),
            ],
          ),
        );
      },
    );
  }
}
