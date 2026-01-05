class ReportDateLimits {
  ReportDateLimits._();

  static final firstDate = DateTime(2020, 1, 1);
  static final lastDate = DateTime(2060, 12, 31);

  static DateTime clamp(DateTime value) {
    if (value.isBefore(firstDate)) return firstDate;
    if (value.isAfter(lastDate)) return lastDate;
    return value;
  }
}
