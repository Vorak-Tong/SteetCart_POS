import 'package:street_cart_pos/domain/models/enums.dart';

class SalePolicy {
  final double vat;
  final double exchangeRate;
  final RoundingMode roundingMode;

  const SalePolicy({
    required this.vat,
    required this.exchangeRate,
    this.roundingMode = RoundingMode.roundUp,
  });

  SalePolicy copyWith({
    double? vat,
    double? exchangeRate,
    RoundingMode? roundingMode,
  }) {
    return SalePolicy(
      vat: vat ?? this.vat,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      roundingMode: roundingMode ?? this.roundingMode,
    );
  }
}
