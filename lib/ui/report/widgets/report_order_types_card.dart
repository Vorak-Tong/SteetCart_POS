import 'dart:math' as math;

import 'package:flutter/material.dart';

class ReportOrderTypesCard extends StatelessWidget {
  const ReportOrderTypesCard({super.key, required this.percentages});

  final Map<String, int> percentages;

  _OrderType? _parseType(String raw) {
    final normalized = raw.trim().toLowerCase().replaceAll(
      RegExp(r'[\s_-]'),
      '',
    );
    switch (normalized) {
      case 'dinein':
        return _OrderType.dineIn;
      case 'takeaway':
        return _OrderType.takeAway;
      case 'delivery':
        return _OrderType.delivery;
      default:
        return null;
    }
  }

  String _labelFor(String raw, _OrderType? type) {
    if (type == null) {
      return raw;
    }
    switch (type) {
      case _OrderType.dineIn:
        return 'Dine-in';
      case _OrderType.takeAway:
        return 'Take-away';
      case _OrderType.delivery:
        return 'Delivery';
    }
  }

  Color _colorFor(ColorScheme scheme, _OrderType? type) {
    switch (type) {
      case _OrderType.dineIn:
        return _derivedColorFromPrimary(scheme, hueOffset: 0);
      case _OrderType.takeAway:
        return _derivedColorFromPrimary(scheme, hueOffset: 120);
      case _OrderType.delivery:
        // Keep away from "error red" while remaining high-contrast.
        return _derivedColorFromPrimary(scheme, hueOffset: 210);
      case null:
        return scheme.outlineVariant;
    }
  }

  Color _derivedColorFromPrimary(
    ColorScheme scheme, {
    required double hueOffset,
  }) {
    final base = HSLColor.fromColor(scheme.primary);

    final saturation = base.saturation.clamp(0.55, 0.85);
    final lightness = scheme.brightness == Brightness.dark
        ? base.lightness.clamp(0.55, 0.70)
        : base.lightness.clamp(0.45, 0.60);

    final hue = (base.hue + hueOffset) % 360;
    return HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
  }

  List<_OrderTypeItem> _buildItems(ThemeData theme) {
    final scheme = theme.colorScheme;

    final orderedEntries = <MapEntry<String, int>>[
      for (final type in _OrderType.values)
        ...percentages.entries.where((e) => _parseType(e.key) == type),
      ...percentages.entries.where((e) => _parseType(e.key) == null),
    ];

    return [
      for (final entry in orderedEntries)
        _OrderTypeItem(
          type: _parseType(entry.key),
          label: _labelFor(entry.key, _parseType(entry.key)),
          percentage: entry.value,
          color: _colorFor(scheme, _parseType(entry.key)),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (percentages.isEmpty) {
      return const SizedBox.shrink();
    }

    final items = _buildItems(theme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Types',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                height: 100,
                width: 100,
                child: CustomPaint(painter: _PieChartPainter(items)),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final item in items)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: item.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.label,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            Text(
                              '${item.percentage}%',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  _PieChartPainter(this.items);

  final List<_OrderTypeItem> items;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    var startAngle = -math.pi / 2;

    for (final item in items) {
      final sweepAngle = (item.percentage / 100) * 2 * math.pi;
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

enum _OrderType { dineIn, takeAway, delivery }

class _OrderTypeItem {
  const _OrderTypeItem({
    required this.type,
    required this.label,
    required this.percentage,
    required this.color,
  });

  final _OrderType? type;
  final String label;
  final int percentage;
  final Color color;
}
