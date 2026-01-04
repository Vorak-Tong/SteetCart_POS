import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/core/utils/number_format.dart';
import 'package:street_cart_pos/ui/core/widgets/product_image.dart';
import 'package:street_cart_pos/ui/core/widgets/quantity_stepper.dart';
import 'package:street_cart_pos/ui/sale/viewmodel/cart_viewmodel.dart';

class CartLineItemTile extends StatelessWidget {
  const CartLineItemTile({
    super.key,
    required this.item,
    required this.onIncrement,
    this.onDecrement,
  });

  final CartLineItem item;
  final VoidCallback onIncrement;
  final VoidCallback? onDecrement;

  List<Widget> _buildSubtitleLines(ThemeData theme) {
    final lines = <Widget>[];

    for (final selection in item.modifierSelections) {
      if (selection.optionNames.isEmpty) {
        continue;
      }
      lines.add(
        Text(
          '${selection.groupName}: ${selection.optionNames.join(', ')}',
          style: theme.textTheme.bodySmall,
        ),
      );
    }

    final notes = item.notes?.trim();
    if (notes != null && notes.isNotEmpty) {
      lines.add(Text(notes, style: theme.textTheme.bodySmall));
    }

    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleLines = _buildSubtitleLines(theme);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 88),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsetsDirectional.fromSTEB(12, 8, 8, 0),
            leading: SizedBox.square(
              dimension: 44,
              child: ProductImage(
                imagePath: item.imagePath,
                showPlaceholderLabel: false,
                placeholderIconSize: 20,
              ),
            ),
            title: Text(item.name),
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
            padding: const EdgeInsets.only(right: 12, bottom: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                formatUsd(item.lineTotal),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
