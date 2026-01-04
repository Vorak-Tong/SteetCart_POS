import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/enums.dart';

class OrderStatusFilterBar extends StatelessWidget {
  const OrderStatusFilterBar({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final SaleStatus value;
  final ValueChanged<SaleStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<SaleStatus>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(
          value: SaleStatus.inPrep,
          label: _IconBelowText(
            text: 'In prep',
            icon: Icons.local_fire_department_outlined,
          ),
        ),
        ButtonSegment(
          value: SaleStatus.ready,
          label: _IconBelowText(
            text: 'Ready',
            icon: Icons.check_circle_outline,
          ),
        ),
        ButtonSegment(
          value: SaleStatus.served,
          label: _IconBelowText(text: 'Served', icon: Icons.done_all),
        ),
        ButtonSegment(
          value: SaleStatus.cancelled,
          label: _IconBelowText(text: 'Cancelled', icon: Icons.cancel_outlined),
        ),
      ],
      selected: {value},
      onSelectionChanged: (selected) => onChanged(selected.first),
    );
  }
}

class _IconBelowText extends StatelessWidget {
  const _IconBelowText({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Icon(icon, size: 18),
      ],
    );
  }
}
