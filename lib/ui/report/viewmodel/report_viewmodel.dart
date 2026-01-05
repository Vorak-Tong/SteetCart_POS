import 'package:flutter/material.dart';
import 'package:street_cart_pos/data/repositories/report_repository.dart';
import 'package:street_cart_pos/utils/command.dart';

class ReportViewModel extends ChangeNotifier {
  final ReportRepository _repository = MockReportRepository();
  
  DateTimeRange _dateRange;
  double _totalRevenue = 0.0;
  List<Map<String, dynamic>> _productRevenues = [];
  int _totalOrders = 0;
  int _totalItemsSold = 0;
  Map<String, int> _orderTypePercentages = {};
  
  late final Command loadReportCommand;

  ReportViewModel()
      : _dateRange = DateTimeRange(
          start: DateTime.now(),
          end: DateTime.now(),
        ) {
    loadReportCommand = Command(_fetchReport);
    // Notify listeners when the command state changes (running/idle)
    loadReportCommand.addListener(notifyListeners);
    loadReportCommand.execute();
  }

  @override
  void dispose() {
    loadReportCommand.removeListener(notifyListeners);
    super.dispose();
  }

  DateTimeRange get dateRange => _dateRange;
  double get totalRevenue => _totalRevenue;
  List<Map<String, dynamic>> get productRevenues => _productRevenues;
  int get totalOrders => _totalOrders;
  int get totalItemsSold => _totalItemsSold;
  Map<String, int> get orderTypePercentages => _orderTypePercentages;

  void setDateRange(DateTimeRange newRange) {
    if (newRange != _dateRange) {
      _dateRange = newRange;
      notifyListeners();
      loadReportCommand.execute();
    }
  }

  Future<void> _fetchReport() async {
    try {
      // Adjust end date to include the full day (up to 23:59:59)
      final start = DateTime(_dateRange.start.year, _dateRange.start.month, _dateRange.start.day);
      final end = DateTime(_dateRange.end.year, _dateRange.end.month, _dateRange.end.day, 23, 59, 59);

      _totalRevenue = await _repository.getTotalRevenue(start, end);
      _productRevenues = await _repository.getTopSellingProducts(start, end);
      _totalOrders = await _repository.getTotalOrders(start, end);
      _totalItemsSold = await _repository.getTotalItemsSold(start, end);
      _orderTypePercentages = await _repository.getOrderTypePercentages(start, end);
    } catch (e) {
      debugPrint('Error fetching report: $e');
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

class MockReportRepository implements ReportRepository {
  @override
  Future<Map<String, int>> getOrderTypePercentages(DateTime start, DateTime end) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return {'Dine-in': 60, 'Take-away': 40};
  }

  @override
  Future<int> getTotalItemsSold(DateTime start, DateTime end) async {
    return 145;
  }

  @override
  Future<int> getTotalOrders(DateTime start, DateTime end) async {
    return 85;
  }

  @override
  Future<double> getTotalRevenue(DateTime start, DateTime end) async {
    return 1250.50;
  }

  @override
  Future<List<Map<String, dynamic>>> getTopSellingProducts(DateTime start, DateTime end) async {
    return [
      {'name': 'Chicken Over Rice', 'percentage': 45, 'imagePath': null},
      {'name': 'Lamb Over Rice', 'percentage': 30, 'imagePath': null},
      {'name': 'Soda Can', 'percentage': 15, 'imagePath': null},
      {'name': 'Falafel Wrap', 'percentage': 10, 'imagePath': null},
    ];
  }
}