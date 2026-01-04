import 'package:flutter/foundation.dart' show ChangeNotifier, setEquals;
import 'package:street_cart_pos/domain/models/product_model.dart';

class ProductSelectionViewModel extends ChangeNotifier {
  ProductSelectionViewModel({required this.product}) {
    _selectedOptionIdsByGroupId = _initSelections(product);
  }

  final Product product;

  int _quantity = 1;
  String _note = '';
  late Map<String, Set<String>> _selectedOptionIdsByGroupId;

  int get quantity => _quantity;
  String get note => _note;

  Map<String, Set<String>> get selectedOptionIdsByGroupId => _selectedOptionIdsByGroupId;

  double get selectedModifiersTotal {
    var total = 0.0;
    for (final group in product.modifierGroups) {
      if (group.priceBehavior == ModifierPriceBehavior.none) {
        continue;
      }

      final selectedIds = _selectedOptionIdsByGroupId[group.id] ?? const <String>{};
      if (selectedIds.isEmpty) {
        continue;
      }

      for (final option in group.modifierOptions) {
        if (!selectedIds.contains(option.id)) {
          continue;
        }
        total += option.price ?? 0;
      }
    }
    return total;
  }

  double get unitTotal => product.basePrice + selectedModifiersTotal;
  double get total => unitTotal * _quantity;

  void setNote(String note) {
    if (_note == note) {
      return;
    }
    _note = note;
    notifyListeners();
  }

  void incrementQuantity() {
    _quantity += 1;
    notifyListeners();
  }

  void decrementQuantity() {
    if (_quantity <= 1) {
      return;
    }
    _quantity -= 1;
    notifyListeners();
  }

  void selectSingle({
    required String groupId,
    required String optionId,
  }) {
    final current = _selectedOptionIdsByGroupId[groupId];
    if (current != null && current.length == 1 && current.contains(optionId)) {
      return;
    }

    _selectedOptionIdsByGroupId = {
      ..._selectedOptionIdsByGroupId,
      groupId: <String>{optionId},
    };
    notifyListeners();
  }

  void toggleMulti({
    required ModifierGroup group,
    required String optionId,
    required bool selected,
  }) {
    final selectedIds = _selectedOptionIdsByGroupId[group.id] ?? const <String>{};
    final next = selectedIds.toSet();

    if (selected) {
      final max = group.maxSelection;
      final hasMax = max > 0;
      if (hasMax && next.length >= max) {
        return;
      }
      next.add(optionId);
    } else {
      next.remove(optionId);
    }

    if (setEquals(selectedIds, next)) {
      return;
    }

    _selectedOptionIdsByGroupId = {
      ..._selectedOptionIdsByGroupId,
      group.id: next,
    };
    notifyListeners();
  }
}

Map<String, Set<String>> _initSelections(Product product) {
  final byGroupId = <String, Set<String>>{};
  for (final group in product.modifierGroups) {
    final defaults = group.modifierOptions.where((o) => o.isDefault).map((o) => o.id);
    if (group.selectionType == ModifierSelectionType.single) {
      final selected = defaults.isNotEmpty
          ? defaults.first
          : (group.modifierOptions.isNotEmpty ? group.modifierOptions.first.id : null);
      byGroupId[group.id] = selected == null ? <String>{} : <String>{selected};
    } else {
      byGroupId[group.id] = defaults.toSet();
    }
  }
  return byGroupId;
}
