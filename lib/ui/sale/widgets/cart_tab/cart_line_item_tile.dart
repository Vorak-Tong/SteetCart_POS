import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/core/utils/number_format.dart';
import 'package:street_cart_pos/ui/core/widgets/product/product_image.dart';
import 'package:street_cart_pos/ui/core/widgets/forms/quantity_stepper.dart';
import 'package:street_cart_pos/domain/models/order_product.dart';

class CartLineItemTile extends StatelessWidget {
  const CartLineItemTile({
    super.key,
    required this.item,
    required this.onIncrement,
    this.onDecrement,
  });

  final OrderProduct item;
  final VoidCallback onIncrement;
  final VoidCallback? onDecrement;

  List<Widget> _buildSubtitleLines(ThemeData theme) {
    final lines = <Widget>[];
    var hasModifiers = false;

    for (final selection in item.modifierSelections) {
      if (selection.optionNames.isEmpty) {
        continue;
      }
      hasModifiers = true;
      lines.add(
        Text(
          '${selection.groupName}: ${selection.optionNames.join(', ')}',
          style: theme.textTheme.bodySmall,
        ),
      );
    }

    if (!hasModifiers) {
      lines.add(
        Text(
          'no modifiers',
          style: theme.textTheme.bodySmall?.copyWith(
            fontStyle: FontStyle.italic,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final notes = item.note?.trim();
    if (notes != null && notes.isNotEmpty) {
      lines.add(Text(notes, style: theme.textTheme.bodySmall));
    }

    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleLines = _buildSubtitleLines(theme);
    final product = item.product;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 92),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsetsDirectional.fromSTEB(12, 8, 8, 0),
              leading: SizedBox.square(
                dimension: 44,
                child: ProductImage(
                  imagePath: product?.imagePath,
                  showPlaceholderLabel: false,
                  placeholderIconSize: 20,
                ),
              ),
              title: Text(product?.name ?? 'Unknown item'),
              subtitle: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (subtitleLines.isNotEmpty)
                    ...subtitleLines
                  else
                    const SizedBox(height: 0),
                  const SizedBox(height: 4),
                ],
              ),
              trailing: QuantityStepper(
                size: QuantityStepperSize.compact,
                quantity: item.quantity,
                onDecrement: onDecrement,
                onIncrement: onIncrement,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12, bottom: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  formatUsd(item.getLineTotal()),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
