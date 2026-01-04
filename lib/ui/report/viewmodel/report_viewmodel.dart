import 'package:flutter/material.dart';
import 'package:street_cart_pos/data/repositories/report_repository.dart';

class ReportViewModel extends ChangeNotifier {
  final ReportRepository _repository = ReportRepository();
  
  DateTimeRange _dateRange;
  double _totalRevenue = 0.0;
  List<Map<String, dynamic>> _productRevenues = [];
  bool _isLoading = false;

  ReportViewModel()
      : _dateRange = DateTimeRange(
          start: DateTime.now(),
          end: DateTime.now(),
        ) {
    _fetchReport();
  }

  DateTimeRange get dateRange => _dateRange;
  double get totalRevenue => _totalRevenue;
  List<Map<String, dynamic>> get productRevenues => _productRevenues;
  bool get isLoading => _isLoading;

  void setDateRange(DateTimeRange newRange) {
    if (newRange != _dateRange) {
      _dateRange = newRange;
      notifyListeners();
      _fetchReport();
    }
  }

  Future<void> _fetchReport() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Adjust end date to include the full day (up to 23:59:59)
      final start = DateTime(_dateRange.start.year, _dateRange.start.month, _dateRange.start.day);
      final end = DateTime(_dateRange.end.year, _dateRange.end.month, _dateRange.end.day, 23, 59, 59);

      _totalRevenue = await _repository.getTotalRevenue(start, end);
      _productRevenues = await _repository.getTopSellingProducts(start, end);
    } catch (e) {
      debugPrint('Error fetching report: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper to format dates nicely (e.g., "Oct 25, 2023")
  String formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }
}