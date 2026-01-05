class SalePolicy {
  final double vat;
  final double exchangeRate;

  const SalePolicy({
    required this.vat,
    required this.exchangeRate,
  });

  SalePolicy copyWith({
    double? vat,
    double? exchangeRate,
  }) {
    return SalePolicy(
      vat: vat ?? this.vat,
      exchangeRate: exchangeRate ?? this.exchangeRate,
    );
  }
}