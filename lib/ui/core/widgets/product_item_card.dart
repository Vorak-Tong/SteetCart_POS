import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/core/utils/number_format.dart';
import 'package:street_cart_pos/ui/core/widgets/product_image.dart';
// import 'package:modular_pos/core/widgets/network_image_helper_stub.dart'
//     if (dart.library.html) 'package:modular_pos/core/widgets/network_image_helper_web.dart';

/// Card for a menu item with image, category, and price.
class ProductItemCard extends StatelessWidget {
  const ProductItemCard({
    super.key,
    this.imagePath,
    required this.title,
    required this.category,
    required this.price,
    this.onTap,
  });

  final String? imagePath;
  final String title;
  final String category;
  final double price;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      color: colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
              child: AspectRatio(
                aspectRatio: 160 / 142,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // imagePath != null && imagePath!.isNotEmpty
                    //     ? buildAdaptiveNetworkImage(
                    //         imagePath!,
                    //         _buildPlaceholder(context),
                    //       )
                    //     : _buildPlaceholder(context),
                    ProductImage(imagePath: imagePath),
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: onTap,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(category, style: textTheme.labelSmall),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatUsd(price),
                          style: textTheme.titleSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
