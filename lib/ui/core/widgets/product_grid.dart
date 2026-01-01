import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import 'package:street_cart_pos/ui/core/widgets/product_item_card.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.products,
    this.onProductTap,
    this.crossAxisCount = 2,
  });

  final List<Product> products;
  final ValueChanged<Product>? onProductTap;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductItemCard(
          title: product.name,
          category: product.category?.name ?? 'Uncategorized',
          price: product.basePrice,
          onTap: onProductTap == null ? null : () => onProductTap!(product),
        );
      },
    );
  }
}

