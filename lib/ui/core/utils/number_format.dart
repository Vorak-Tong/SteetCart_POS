String formatIntWithThousandsSeparator(int value) {
  final sign = value < 0 ? '-' : '';
  final digits = value.abs().toString();
  final formatted = digits.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]},',
  );
  return '$sign$formatted';
}

String formatDecimalWithThousandsSeparator(
  double value, {
  int fractionDigits = 2,
}) {
  final sign = value < 0 ? '-' : '';
  final fixed = value.abs().toStringAsFixed(fractionDigits);
  final parts = fixed.split('.');

  final integerPart = parts[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]},',
  );

  if (fractionDigits == 0 || parts.length == 1) {
    return '$sign$integerPart';
  }
  return '$sign$integerPart.${parts[1]}';
}

String formatUsd(double amount) {
  return '\$${formatDecimalWithThousandsSeparator(amount, fractionDigits: 2)}';
}

String formatKhr(int amount) {
  return 'KHR ${formatIntWithThousandsSeparator(amount)}';
}
