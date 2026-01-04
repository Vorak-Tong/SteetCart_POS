import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/enums.dart';

class CartOrderTypeSection extends StatelessWidget {
  const CartOrderTypeSection({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final OrderType value;
  final ValueChanged<OrderType> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Type',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<OrderType>(
          segments: const [
            ButtonSegment(
              value: OrderType.dineIn,
              label: Text('Dine in'),
              icon: Icon(Icons.restaurant),
            ),
            ButtonSegment(
              value: OrderType.takeAway,
              label: Text('Take away'),
              icon: Icon(Icons.shopping_bag_outlined),
            ),
            ButtonSegment(
              value: OrderType.delivery,
              label: Text('Delivery'),
              icon: Icon(Icons.local_shipping_outlined),
            ),
          ],
          selected: {value},
          onSelectionChanged: (selected) => onChanged(selected.first),
        ),
      ],
    );
  }
}
