import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/menu/utils/modifier_form_route_args.dart';

class ModifierFormHeader extends StatelessWidget {
  const ModifierFormHeader({
    super.key,
    required this.mode,
    required this.onClose,
    required this.onToggleEdit,
  });

  final ModifierFormMode mode;
  final VoidCallback onClose;
  final VoidCallback onToggleEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close),
          onPressed: onClose,
        ),
        const Spacer(),
        if (mode != ModifierFormMode.create)
          mode == ModifierFormMode.edit
              ? TextButton(
                  onPressed: onToggleEdit,
                  child: const Text('Cancel'),
                )
              : IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  onPressed: onToggleEdit,
                ),
      ],
    );
  }
}

