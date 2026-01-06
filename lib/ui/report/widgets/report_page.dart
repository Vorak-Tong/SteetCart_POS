import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/report/viewmodel/report_viewmodel.dart';
import 'package:street_cart_pos/ui/report/widgets/report_date_range_card.dart';
import 'package:street_cart_pos/ui/report/widgets/report_kpi_section.dart';
import 'package:street_cart_pos/ui/report/widgets/report_loading_overlay.dart';
import 'package:street_cart_pos/ui/report/widgets/report_order_types_card.dart';
import 'package:street_cart_pos/ui/report/widgets/report_top_products_section.dart';
import 'package:street_cart_pos/domain/models/report_model.dart';

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
    final firstDate = Report.firstDate;
    final lastDate = Report.lastDate;

    final initialStart = Report.clampDate(_viewModel.dateRange.start);
    final initialEnd = Report.clampDate(_viewModel.dateRange.end);
    final initialDateRange = DateTimeRange(
      start: initialStart.isAfter(initialEnd) ? initialEnd : initialStart,
      end: initialEnd.isBefore(initialStart) ? initialStart : initialEnd,
    );

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: initialDateRange,
    );
    if (picked != null) {
      _viewModel.setDateRange(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Text(
                          'Reporting for:',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ReportDateRangeCard(
                            label:
                                '${_viewModel.formatDate(_viewModel.dateRange.start)} - ${_viewModel.formatDate(_viewModel.dateRange.end)}',
                            onTap: _selectDateRange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: ReportKpiSection(
                      totalRevenue: _viewModel.totalRevenue,
                      totalOrders: _viewModel.totalOrders,
                      totalItemsSold: _viewModel.totalItemsSold,
                      refreshing: _viewModel.loadReportCommand.running,
                      onRefresh: _viewModel.loadReportCommand.running
                          ? null
                          : () => _viewModel.loadReportCommand.execute(null),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: ReportOrderTypesCard(
                      percentages: _viewModel.orderTypePercentages,
                    ),
                  ),
                ),
                if (_viewModel.orderTypePercentages.isNotEmpty)
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: ReportTopProductsSliver(
                    products: _viewModel.productRevenues,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
            ReportLoadingOverlay(visible: _viewModel.loadReportCommand.running),
          ],
        );
      },
    );
  }
}
