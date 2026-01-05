import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';

class ModifierViewModel extends ChangeNotifier {
  final MenuRepository _repository = MenuRepository();
  final Set<String> _pendingDeleteIds = {};
  bool _disposed = false;

  ModifierViewModel() {
    _repository.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _disposed = true;
    _repository.removeListener(notifyListeners);
    super.dispose();
  }

  List<ModifierGroup> get modifierGroups => List.unmodifiable(
    _repository.modifierGroups.where((g) => !_pendingDeleteIds.contains(g.id)),
  );

  Future<void> addModifierGroup(ModifierGroup group) async {
    await _repository.addModifierGroup(group);
  }

  Future<void> updateModifierGroup(ModifierGroup group) async {
    await _repository.updateModifierGroup(group);
  }

  Future<void> deleteModifierGroup(ModifierGroup group) async {
    if (_pendingDeleteIds.contains(group.id)) return;
    _pendingDeleteIds.add(group.id);
    if (!_disposed) notifyListeners();

    try {
      await _repository.deleteModifierGroup(group.id);
    } catch (_) {
      _pendingDeleteIds.remove(group.id);
      if (!_disposed) notifyListeners();
      rethrow;
    } finally {
      _pendingDeleteIds.remove(group.id);
    }
  }
}
