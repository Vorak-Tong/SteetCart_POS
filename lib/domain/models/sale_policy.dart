class SalePolicy {
  final int vatPercent;
  final int usdToKhrRate;

  const SalePolicy({
    this.vatPercent = 0,
    this.usdToKhrRate = 4000,
  });

  SalePolicy copyWith({
    int? vatPercent,
    int? usdToKhrRate,
  }) {
    return SalePolicy(
      vatPercent: vatPercent ?? this.vatPercent,
      usdToKhrRate: usdToKhrRate ?? this.usdToKhrRate,
    );
  }

  @override
  String toString() => 'SalePolicy(vatPercent: $vatPercent, usdToKhrRate: $usdToKhrRate)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SalePolicy && other.vatPercent == vatPercent && other.usdToKhrRate == usdToKhrRate;
  }

  @override
  int get hashCode => vatPercent.hashCode ^ usdToKhrRate.hashCode;
}