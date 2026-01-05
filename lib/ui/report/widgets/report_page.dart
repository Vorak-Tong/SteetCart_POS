import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/core/widgets/product_image.dart';
import 'package:street_cart_pos/ui/report/viewmodel/report_viewmodel.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final ReportViewModel _viewModel = ReportViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _viewModel.dateRange,
    );
    if (picked != null) {
      _viewModel.setDateRange(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Header Row with Date Picker
                InkWell(
                onTap: _selectDateRange,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month, size: 20, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${_viewModel.formatDate(_viewModel.dateRange.start)} - ${_viewModel.formatDate(_viewModel.dateRange.end)}',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down, size: 20, color: colorScheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Total Revenue Card
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
                      color: colorScheme.primary.withOpacity(0.3),
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
                        Icon(Icons.attach_money, color: colorScheme.onPrimary.withOpacity(0.9), size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Total Revenue',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimary.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${_viewModel.totalRevenue.toStringAsFixed(2)}',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Summary Row (Orders & Items)
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'Total Orders',
                      _viewModel.totalOrders.toString(),
                      Icons.receipt_long,
                      colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'Items Sold',
                      _viewModel.totalItemsSold.toString(),
                      Icons.shopping_bag,
                      colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Order Types
              if (_viewModel.orderTypePercentages.isNotEmpty) ...[
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
                        child: CustomPaint(
                          painter: _PieChartPainter(
                            _viewModel.orderTypePercentages,
                            [
                              colorScheme.primary,
                              colorScheme.tertiary,
                              colorScheme.secondary,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _viewModel.orderTypePercentages.entries.toList().asMap().entries.map((entry) {
                            final index = entry.key;
                            final key = entry.value.key;
                            final value = entry.value.value;
                            final color = [
                              colorScheme.primary,
                              colorScheme.tertiary,
                              colorScheme.secondary,
                            ][index % 3];

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      key,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                  Text(
                                    '$value%',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Top Products Header
              Text(
                'Top Products',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Product List or Empty State
              if (_viewModel.productRevenues.isEmpty)
                Container(
                  height: 300,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart, size: 64, color: colorScheme.outline.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'No sales data for this period',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...List.generate(_viewModel.productRevenues.length, (index) {
                  final product = _viewModel.productRevenues[index];
                      final percentage = product['percentage'] as int;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Rank
                            SizedBox(
                              width: 30,
                              child: Text(
                                '#${index + 1}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Image
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: ProductImage(
                                imagePath: product['imagePath'],
                                borderRadius: 12,
                                showPlaceholderLabel: false,
                                placeholderIconSize: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        product['name'],
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '$percentage%',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: percentage / 100,
                                      minHeight: 6,
                                      backgroundColor: colorScheme.surfaceVariant.withOpacity(0.5),
                                      valueColor: AlwaysStoppedAnimation(
                                        percentage > 30 ? colorScheme.primary : colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            if (_viewModel.loadReportCommand.running)
              Container(
                color: Colors.black.withOpacity(0.1),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, IconData icon, Color iconColor) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(
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

class _PieChartPainter extends CustomPainter {
  final Map<String, int> data;
  final List<Color> colors;

  _PieChartPainter(this.data, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    var startAngle = -math.pi / 2;

    int i = 0;
    for (var entry in data.entries) {
      final sweepAngle = (entry.value / 100) * 2 * math.pi;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
      i++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
