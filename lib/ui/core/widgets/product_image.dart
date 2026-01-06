import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/core/utils/local_file_image.dart';
import 'package:street_cart_pos/ui/core/widgets/dashed_border_painter.dart';

String productSelectionHeroTag(String productId) =>
    'product-selection-$productId';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.imagePath,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
    this.placeholderColor,
    this.showPlaceholderLabel = true,
    this.placeholderLabel = 'No image',
    this.placeholderIcon = Icons.image_outlined,
    this.placeholderIconSize = 32,
  });

  final String? imagePath;
  final double borderRadius;
  final BoxFit fit;

  final Color? placeholderColor;
  final bool showPlaceholderLabel;
  final String placeholderLabel;
  final IconData placeholderIcon;
  final double placeholderIconSize;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    if (path == null || path.isEmpty) {
      return _buildPlaceholder(context);
    }

    if (path.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          path,
          fit: fit,
          errorBuilder: (_, __, ___) => _buildPlaceholder(context),
        ),
      );
    }

    final provider = localFileImageProvider(path);
    if (provider == null) {
      return _buildPlaceholder(context);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image(
        image: provider,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildPlaceholder(context),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    final color = placeholderColor ?? theme.colorScheme.primary;
    final textStyle = theme.textTheme.bodySmall?.copyWith(
      color: color,
      fontWeight: FontWeight.w600,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CustomPaint(
        foregroundPainter: DashedBorderPainter(
          color: color,
          strokeWidth: 1.4,
          dashWidth: 6,
          dashSpace: 4,
          borderRadius: borderRadius,
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(placeholderIcon, color: color, size: placeholderIconSize),
              if (showPlaceholderLabel) ...[
                const SizedBox(height: 6),
                Text(placeholderLabel, style: textStyle),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
