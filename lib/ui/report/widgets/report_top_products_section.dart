import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/core/widgets/product_image.dart';

class ReportTopProductsSliver extends StatelessWidget {
  const ReportTopProductsSliver({super.key, required this.products});

  final List<Map<String, dynamic>> products;

  String _soldLabel(Object? raw) {
    if (raw is num) {
      return 'Sold: ${raw.toInt()}';
    }
    if (raw is String) {
      final parsed = int.tryParse(raw);
      if (parsed != null) {
        return 'Sold: $parsed';
      }
    }
    return 'Sold: —';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final childCount = products.isEmpty ? 2 : 1 + products.length;

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Top Products',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        if (products.isEmpty) {
          return Container(
            height: 300,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bar_chart,
                  size: 64,
                  color: colorScheme.outline.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No sales data for this period',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        final productIndex = index - 1;
        final product = products[productIndex];
        final percentage = product['percentage'] as int;
        final revenueColor = percentage > 30
            ? colorScheme.primary
            : colorScheme.secondary;
        final soldLabel = _soldLabel(product['unitsSold']);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      '#${productIndex + 1}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: ProductImage(
                      imagePath: product['imagePath'],
                      borderRadius: 12,
                      showPlaceholderLabel: false,
                      placeholderIconSize: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                product['name'],
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _MetricChip(
                                  label: '$percentage% revenue',
                                  color: revenueColor,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  soldLabel,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 6,
                            backgroundColor: colorScheme.surfaceVariant
                                .withOpacity(0.5),
                            valueColor: AlwaysStoppedAnimation(revenueColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }, childCount: childCount),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
