import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import 'package:street_cart_pos/utils/command.dart';

class ModifierViewModel extends ChangeNotifier {
  final MenuRepository _repository = MenuRepository();
  final Set<String> _pendingDeleteIds = {};
  bool _disposed = false;
  bool _hasLoadedOnce = false;

  late final CommandWithParam<void, void> loadMenuCommand;
  late final CommandWithParam<ModifierGroup, void> addModifierGroupCommand;
  late final CommandWithParam<ModifierGroup, void> updateModifierGroupCommand;
  late final CommandWithParam<ModifierGroup, void> _deleteModifierGroupCommand;

  ModifierViewModel() {
    _repository.addListener(notifyListeners);

    loadMenuCommand = CommandWithParam((_) => _loadMenu());
    addModifierGroupCommand = CommandWithParam(_addModifierGroup);
    updateModifierGroupCommand = CommandWithParam(_updateModifierGroup);
    _deleteModifierGroupCommand = CommandWithParam(_deleteModifierGroup);

    loadMenuCommand.addListener(notifyListeners);
    addModifierGroupCommand.addListener(notifyListeners);
    updateModifierGroupCommand.addListener(notifyListeners);
    _deleteModifierGroupCommand.addListener(notifyListeners);

    loadMenuCommand.execute(null);
  }

  @override
  void dispose() {
    _disposed = true;
    _repository.removeListener(notifyListeners);
    loadMenuCommand.removeListener(notifyListeners);
    addModifierGroupCommand.removeListener(notifyListeners);
    updateModifierGroupCommand.removeListener(notifyListeners);
    _deleteModifierGroupCommand.removeListener(notifyListeners);
    super.dispose();
  }

  bool get loading => loadMenuCommand.running;
  bool get hasLoadedOnce => _hasLoadedOnce;
  bool get saving =>
      addModifierGroupCommand.running || updateModifierGroupCommand.running;
  bool get deleting => _deleteModifierGroupCommand.running;

  List<ModifierGroup> get modifierGroups => List.unmodifiable(
    _repository.modifierGroups.where((g) => !_pendingDeleteIds.contains(g.id)),
  );

  Future<void> addModifierGroup(ModifierGroup group) async {
    await addModifierGroupCommand.execute(group);
  }

  Future<void> updateModifierGroup(ModifierGroup group) async {
    await updateModifierGroupCommand.execute(group);
  }

  Future<void> deleteModifierGroup(ModifierGroup group) async {
    await _deleteModifierGroupCommand.execute(group);
  }

  Future<void> _loadMenu() async {
    await _repository.init();
    _hasLoadedOnce = true;
    notifyListeners();
  }

  Future<void> _addModifierGroup(ModifierGroup group) async {
    await _repository.addModifierGroup(group);
  }

  Future<void> _updateModifierGroup(ModifierGroup group) async {
    await _repository.updateModifierGroup(group);
  }

  Future<void> _deleteModifierGroup(ModifierGroup group) async {
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
