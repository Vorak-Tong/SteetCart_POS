import 'package:flutter/material.dart';

class ReportKpiSection extends StatelessWidget {
  const ReportKpiSection({
    super.key,
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalItemsSold,
    this.onRefresh,
    this.refreshing = false,
  });

  static const totalRevenueKey = ValueKey('report_total_revenue');
  static const totalOrdersKey = ValueKey('report_total_orders');
  static const totalItemsSoldKey = ValueKey('report_total_items_sold');

  final double totalRevenue;
  final int totalOrders;
  final int totalItemsSold;
  final VoidCallback? onRefresh;
  final bool refreshing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.tertiary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    color: colorScheme.onPrimary.withValues(alpha: 0.9),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total Revenue',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                  if (onRefresh != null) ...[
                    const Spacer(),
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: refreshing ? null : onRefresh,
                      icon: Icon(
                        Icons.refresh_outlined,
                        color: colorScheme.onPrimary.withValues(alpha: 0.9),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                key: totalRevenueKey,
                '\$${totalRevenue.toStringAsFixed(2)}',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: _ReportSummaryCard(
                title: 'Total Orders',
                value: '$totalOrders',
                valueKey: totalOrdersKey,
                icon: Icons.receipt_long,
                iconColor: colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ReportSummaryCard(
                title: 'Items Sold',
                value: '$totalItemsSold',
                valueKey: totalItemsSoldKey,
                icon: Icons.shopping_bag,
                iconColor: colorScheme.tertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReportSummaryCard extends StatelessWidget {
  const _ReportSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.valueKey,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(
            key: valueKey,
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
