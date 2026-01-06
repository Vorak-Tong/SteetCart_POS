import 'model_ids.dart';


class Report {
  static final DateTime firstDate = DateTime(2020, 1, 1);
  static final DateTime lastDate = DateTime(2060, 12, 31);

  static DateTime clampDate(DateTime date) {
    if (date.isBefore(firstDate)) return firstDate;
    if (date.isAfter(lastDate)) return lastDate;
    return date;
  }

  final String id;
  final DateTime startDate;
  final DateTime endDate;

  Report({String? id, required this.startDate, required this.endDate})
    : id = id ?? uuid.v4();

  Report copyWith({String? id, DateTime? startDate, DateTime? endDate}) {
    return Report(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  String toString() =>
      'Report(id: $id, startDate: $startDate, endDate: $endDate)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Report &&
        other.id == id &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => id.hashCode ^ startDate.hashCode ^ endDate.hashCode;
}
