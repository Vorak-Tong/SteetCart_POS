import 'package:street_cart_pos/data/local/app_database.dart';
import 'package:street_cart_pos/domain/models/sale_policy.dart';

abstract class SalePolicyRepository {
  Future<SalePolicy> getSalePolicy();
  Future<void> updateSalePolicy(SalePolicy policy);
}

class SalePolicyRepositoryImpl implements SalePolicyRepository {
  @override
  Future<SalePolicy> getSalePolicy() async {
    final db = await AppDatabase.instance();
    final result = await db.query('sale_policy', limit: 1);

    if (result.isNotEmpty) {
      return SalePolicy(
        vat: (result.first['vat'] as num).toDouble(),
        exchangeRate: (result.first['exchange_rate'] as num).toDouble(),
      );
    }
    return const SalePolicy(vat: 0, exchangeRate: 4000);
  }

  @override
  Future<void> updateSalePolicy(SalePolicy policy) async {
    final db = await AppDatabase.instance();
    await db.transaction((txn) async {
      await txn.delete('sale_policy');
      await txn.insert('sale_policy', {
        'vat': policy.vat,
        'exchange_rate': policy.exchangeRate,
      });
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