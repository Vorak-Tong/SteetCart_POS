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
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                Expanded(
                  child: Center(
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
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: _viewModel.productRevenues.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = _viewModel.productRevenues[index];
                      final percentage = product['percentage'] as int;

                      return Card(
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
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
