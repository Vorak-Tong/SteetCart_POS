import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';

class ProductSearchBar extends StatefulWidget {
  const ProductSearchBar({
    super.key,
    required this.products,
    required this.query,
    required this.onQueryChanged,
    required this.selectedCategoryId,
    this.allCategoryId = '__all__',
    this.uncategorizedCategoryId,
    this.archivedCategoryId,
  });

  final List<Product> products;
  final String query;
  final ValueChanged<String> onQueryChanged;

  final String selectedCategoryId;
  final String allCategoryId;
  final String? uncategorizedCategoryId;
  final String? archivedCategoryId;

  @override
  State<ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<ProductSearchBar> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.query,
  );

  @override
  void didUpdateWidget(covariant ProductSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _controller.text) {
      _controller
        ..text = widget.query
        ..selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Product>(
      displayStringForOption: (option) => option.name,
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.trim().toLowerCase();
        if (query.isEmpty) {
          return const Iterable<Product>.empty();
        }

        return widget.products.where((product) {
          final selected = widget.selectedCategoryId;
          final inCategory =
              selected == widget.allCategoryId ||
              (widget.uncategorizedCategoryId != null &&
                  selected == widget.uncategorizedCategoryId &&
                  product.category == null) ||
              (widget.archivedCategoryId != null &&
                  selected == widget.archivedCategoryId &&
                  !product.isActive) ||
              product.category?.id == selected;
          return inCategory && product.name.toLowerCase().contains(query);
        });
      },
      onSelected: (product) => widget.onQueryChanged(product.name),
      fieldViewBuilder: (context, _, focusNode, onFieldSubmitted) {
        return TextField(
          controller: _controller,
          focusNode: focusNode,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search products',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: widget.query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear',
                    onPressed: () => widget.onQueryChanged(''),
                    icon: const Icon(Icons.clear),
                  ),
          ),
          onChanged: widget.onQueryChanged,
          onSubmitted: (_) => onFieldSubmitted(),
        );
      },
    );
  }
}
