import '../local/dao/sale_policy_dao.dart';
import '../../domain/models/sale_policy.dart';

class SalePolicyRepository {
  final _dao = SalePolicyDao();

  Future<SalePolicy> getPolicy() async {
    final row = await _dao.get();
    if (row != null) {
      return SalePolicy(
        vatPercent: row[SalePolicyDao.colVatPercent] as int,
        usdToKhrRate: row[SalePolicyDao.colUsdToKhrRate] as int,
      );
    }
    // Return default policy if none exists in DB
    return SalePolicy();
  }

  Future<void> savePolicy(SalePolicy policy) async {
    await _dao.insertOrUpdate({
      SalePolicyDao.colVatPercent: policy.vatPercent,
      SalePolicyDao.colUsdToKhrRate: policy.usdToKhrRate,
    });
  }
}