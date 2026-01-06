import 'package:flutter/foundation.dart';
import 'package:street_cart_pos/data/repositories/sale_policy_repository.dart';
import 'package:street_cart_pos/domain/models/sale_policy.dart';
import 'package:street_cart_pos/utils/command.dart';

class PaymentPolicyViewModel extends ChangeNotifier {
  final SalePolicyRepository _repository;

  SalePolicy _policy = const SalePolicy(vat: 0, exchangeRate: 4000);

  late final CommandWithParam<void, void> loadPolicyCommand;
  late final CommandWithParam<SalePolicy, void> updatePolicyCommand;

  PaymentPolicyViewModel({SalePolicyRepository? repository})
    : _repository = repository ?? SalePolicyRepositoryImpl() {
    loadPolicyCommand = CommandWithParam((_) => _loadPolicy());
    updatePolicyCommand = CommandWithParam(_updatePolicy);

    // Notify listeners when commands change state (running/idle)
    loadPolicyCommand.addListener(notifyListeners);
    updatePolicyCommand.addListener(notifyListeners);

    loadPolicyCommand.execute(null);
  }

  SalePolicy get policy => _policy;

  Future<void> _loadPolicy() async {
    try {
      final result = await _repository.getSalePolicy();
      _policy = result;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading policy: $e');
    }
  }

  Future<void> _updatePolicy(SalePolicy newPolicy) async {
    try {
      await _repository.updateSalePolicy(newPolicy);
      _policy = newPolicy;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating policy: $e');
      rethrow;
    }
  }

  // --- Validation Logic ---

  String? validateVat(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final n = double.tryParse(value);
    if (n == null) return 'Invalid number';
    if (n < 0 || n > 100) return 'Must be 0-100';
    return null;
  }

  String? validateExchangeRate(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final n = double.tryParse(value);
    if (n == null) return 'Invalid number';
    if (n <= 0) return 'Must be positive';
    return null;
  }

  void updateVat(String value) {
    final newVat = double.tryParse(value) ?? 0;
    updatePolicyCommand.execute(_policy.copyWith(vat: newVat));
  }

  void updateExchangeRate(String value) {
    final newRate = double.tryParse(value) ?? 4000;
    updatePolicyCommand.execute(_policy.copyWith(exchangeRate: newRate));
  }

  @override
  void dispose() {
    loadPolicyCommand.removeListener(notifyListeners);
    updatePolicyCommand.removeListener(notifyListeners);
    super.dispose();
  }
}
