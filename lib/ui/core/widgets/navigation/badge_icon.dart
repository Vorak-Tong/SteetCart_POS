import 'package:flutter/material.dart';

class BadgeIcon extends StatelessWidget {
  const BadgeIcon({
    super.key,
    required this.count,
    required this.child,
    this.showZero = true,
  });

  final int count;
  final Widget child;
  final bool showZero;

  @override
  Widget build(BuildContext context) {
    final safeCount = count < 0 ? 0 : count;
    if (!showZero && safeCount == 0) return child;

    final colorScheme = Theme.of(context).colorScheme;
    final badgeBackground =
        safeCount == 0 ? Colors.grey : colorScheme.error;
    final badgeForeground = Colors.white;
    final badgeText = safeCount > 99 ? '99+' : '$safeCount';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -6,
          top: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: badgeBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            alignment: Alignment.center,
            child: Text(
              badgeText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: badgeForeground,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
