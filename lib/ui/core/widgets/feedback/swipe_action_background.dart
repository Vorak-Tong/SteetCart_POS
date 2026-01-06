import 'package:flutter/material.dart';

class SwipeActionBackground extends StatelessWidget {
  const SwipeActionBackground({
    super.key,
    required this.alignment,
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
    this.label,
    this.labelColor,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final Alignment alignment;
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final String? label;
  final Color? labelColor;
  final double borderRadius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final textColor = labelColor ?? iconColor;
    final showLabel = label != null && label!.trim().isNotEmpty;
    final isRight = alignment.x > 0;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: padding,
      alignment: alignment,
      child: Row(
        mainAxisSize: isRight ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment: isRight
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isRight) ...[
            Icon(icon, color: iconColor),
            if (showLabel) ...[
              const SizedBox(width: 8),
              Text(
                label!,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              ),
            ],
          ] else ...[
            if (showLabel) ...[
              Text(
                label!,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
            ],
            Icon(icon, color: iconColor),
          ],
        ],
      ),
    );
  }
}
