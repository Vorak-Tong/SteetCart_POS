import 'package:flutter_test/flutter_test.dart';
import 'package:street_cart_pos/data/repositories/sale_policy_repository.dart';
import 'package:street_cart_pos/domain/models/sale_policy.dart';
import '../../helpers/database_test_helper.dart';

void main() {
  setupDatabaseTests();

  test('SalePolicyRepository: Get Default and Update', () async {
    final repo = SalePolicyRepositoryImpl();

    // 1. Update Policy
    final newPolicy = SalePolicy(vat: 10, exchangeRate: 4100);
    await repo.updateSalePolicy(newPolicy);

    // 2. Verify
    final fetchedPolicy = await repo.getSalePolicy();
    expect(fetchedPolicy.vat, 10);
    expect(fetchedPolicy.exchangeRate, 4100);
  });
}
