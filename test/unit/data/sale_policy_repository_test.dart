import 'package:flutter_test/flutter_test.dart';
import 'package:street_cart_pos/data/repositories/sale_policy_repository.dart';
import 'package:street_cart_pos/domain/models/sale_policy.dart';
import '../../helpers/database_test_helper.dart';

void main() {
  setupDatabaseTests();

  test('SalePolicyRepository: Get Default and Update', () async {
    final repo = SalePolicyRepository();

    // 1. Update Policy
    final newPolicy = SalePolicy(vatPercent: 10, usdToKhrRate: 4100);
    await repo.savePolicy(newPolicy);

    // 2. Verify
    final fetchedPolicy = await repo.getPolicy();
    expect(fetchedPolicy.vatPercent, 10);
    expect(fetchedPolicy.usdToKhrRate, 4100);
  });
}