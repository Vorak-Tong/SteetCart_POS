import 'package:flutter/material.dart';

enum QuantityStepperSize {
  compact,
  regular,
}

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    this.size = QuantityStepperSize.regular,
  });

  final int quantity;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;
  final QuantityStepperSize size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final buttonExtent = size == QuantityStepperSize.compact ? 28.0 : 40.0;
    final iconSize = size == QuantityStepperSize.compact ? 16.0 : 22.0;
    final valueWidth = size == QuantityStepperSize.compact ? 22.0 : 28.0;
    final valueStyle = (size == QuantityStepperSize.compact
            ? theme.textTheme.titleSmall
            : theme.textTheme.titleMedium)
        ?.copyWith(fontWeight: FontWeight.w700);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepButton(
              icon: Icons.remove,
              iconSize: iconSize,
              extent: buttonExtent,
              onTap: onDecrement,
              tooltip: 'Decrease quantity',
            ),
            SizedBox(
              width: valueWidth,
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: valueStyle,
              ),
            ),
            _StepButton(
              icon: Icons.add,
              iconSize: iconSize,
              extent: buttonExtent,
              onTap: onIncrement,
              tooltip: 'Increase quantity',
            ),
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.iconSize,
    required this.extent,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final double iconSize;
  final double extent;
  final VoidCallback? onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;

    final iconColor = enabled ? colorScheme.onSurface : colorScheme.onSurfaceVariant;

    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: extent / 2,
        child: SizedBox(
          width: extent,
          height: extent,
          child: Center(
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
