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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<OrderType>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: OrderType.dineIn,
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Dine in'),
                    SizedBox(height: 4),
                    Icon(Icons.restaurant, size: 18),
                  ],
                ),
              ),
              ButtonSegment(
                value: OrderType.takeAway,
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Take away'),
                    SizedBox(height: 4),
                    Icon(Icons.shopping_bag_outlined, size: 18),
                  ],
                ),
              ),
              ButtonSegment(
                value: OrderType.delivery,
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Delivery'),
                    SizedBox(height: 4),
                    Icon(Icons.local_shipping_outlined, size: 18),
                  ],
                ),
              ),
            ],
            selected: {value},
            onSelectionChanged: (selected) => onChanged(selected.first),
          ),
        ),
      ],
    );
  }
}
