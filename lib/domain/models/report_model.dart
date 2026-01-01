import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Report {
  final String id;
  final DateTime startDate;
  final DateTime endDate;

  Report({
    String? id,
    required this.startDate,
    required this.endDate,
  }) : id = id ?? uuid.v4();

  void getDateRangeSummary() {
    // Logic to summarize data
  }
}