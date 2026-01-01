import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/core/widgets/dashed_border_painter.dart';
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
                    _buildPlaceholder(context),
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
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(category, style: textTheme.labelSmall),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${price.toStringAsFixed(2)}',
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

  /// A private helper widget to show a consistent placeholder.
  Widget _buildPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    final textStyle =
        theme.textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600);

    const radius = 12.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CustomPaint(
        foregroundPainter: DashedBorderPainter(
          color: color,
          strokeWidth: 1.4,
          dashWidth: 6,
          dashSpace: 4,
          borderRadius: radius,
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image_outlined, color: color, size: 32),
              const SizedBox(height: 6),
              Text('No image', style: textStyle),
            ],
          ),
        ),
      ),
    );
  }
}
