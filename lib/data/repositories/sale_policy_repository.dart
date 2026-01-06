import '../../domain/models/sale_policy.dart';
import '../../domain/models/enums.dart';
import '../local/dao/sale_policy_dao.dart';

abstract class SalePolicyRepository {
  Future<SalePolicy> getSalePolicy();
  Future<void> updateSalePolicy(SalePolicy policy);
}

class SalePolicyRepositoryImpl implements SalePolicyRepository {
  final SalePolicyDao _dao = SalePolicyDao();

  @override
  Future<SalePolicy> getSalePolicy() async {
    final row = await _dao.get();
    if (row != null) {
      final roundingRaw =
          row[SalePolicyDao.colRoundingMode] as String? ?? 'roundUp';
      final roundingMode = RoundingMode.values.any((x) => x.name == roundingRaw)
          ? RoundingMode.values.byName(roundingRaw)
          : RoundingMode.roundUp;
      return SalePolicy(
        vat: (row[SalePolicyDao.colVatPercent] as num).toDouble(),
        exchangeRate: (row[SalePolicyDao.colUsdToKhrRate] as num).toDouble(),
        roundingMode: roundingMode,
      );
    }

    const fallback = SalePolicy(vat: 0, exchangeRate: 4000);
    await _dao.insertOrUpdate({
      SalePolicyDao.colVatPercent: fallback.vat,
      SalePolicyDao.colUsdToKhrRate: fallback.exchangeRate,
      SalePolicyDao.colRoundingMode: fallback.roundingMode.name,
    });
    return fallback;
  }

  @override
  Future<void> updateSalePolicy(SalePolicy policy) async {
    await _dao.insertOrUpdate({
      SalePolicyDao.colVatPercent: policy.vat,
      SalePolicyDao.colUsdToKhrRate: policy.exchangeRate,
      SalePolicyDao.colRoundingMode: policy.roundingMode.name,
    });
  }
}

class MockSalePolicyRepository implements SalePolicyRepository {
  SalePolicy _policy = const SalePolicy(vat: 0, exchangeRate: 4000);

  @override
  Future<SalePolicy> getSalePolicy() async {
    // Simulate database delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _policy;
  }

  @override
  Future<void> updateSalePolicy(SalePolicy policy) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _policy = policy;
  }
}
