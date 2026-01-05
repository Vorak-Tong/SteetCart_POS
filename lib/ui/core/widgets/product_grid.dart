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

  double _childAspectRatioFor(BuildContext context, double maxWidth) {
    const crossAxisSpacing = 12.0;

    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final tileWidth =
        (maxWidth - crossAxisSpacing * (crossAxisCount - 1)) / crossAxisCount;

    // ProductItemCard uses an image AspectRatio of 160/142.
    final imageHeight = tileWidth * (142 / 160);

    // Rough minimum space for title + category/price row, scaled for accessibility.
    final minBottomContentHeight = 56.0 * textScale;

    // ProductItemCard vertical paddings:
    // - image top padding: 10
    // - details padding: 8(top)+8(bottom) = 16
    final minTileHeight = 10.0 + imageHeight + 16.0 + minBottomContentHeight;

    // childAspectRatio = width / height
    final ratio = tileWidth / minTileHeight;
    return ratio.clamp(0.62, 0.82);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final childAspectRatio = _childAspectRatioFor(
          context,
          constraints.maxWidth,
        );

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductItemCard(
              imagePath: product.imagePath,
              title: product.name,
              category: product.category?.name ?? 'Uncategorized',
              price: product.basePrice,
              onTap: onProductTap == null ? null : () => onProductTap!(product),
            );
          },
        );
      },
    );
  }
}
