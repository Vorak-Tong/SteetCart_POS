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

  Report copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Report(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  String toString() => 'Report(id: $id, startDate: $startDate, endDate: $endDate)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Report && other.id == id && other.startDate == startDate && other.endDate == endDate;
  }

  @override
  int get hashCode => id.hashCode ^ startDate.hashCode ^ endDate.hashCode;
}