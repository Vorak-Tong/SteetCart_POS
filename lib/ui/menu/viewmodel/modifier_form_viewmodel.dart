import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/modifier_enums.dart';
import 'package:street_cart_pos/domain/models/modifier_group.dart';
import 'package:street_cart_pos/domain/models/modifier_option.dart';
import 'package:street_cart_pos/ui/menu/utils/modifier_form_route_args.dart';
import 'package:street_cart_pos/utils/command.dart';
import 'package:uuid/uuid.dart';

class ModifierFormViewModel extends ChangeNotifier {
  ModifierFormViewModel({
    required ModifierFormMode mode,
    required this.onSave,
    ModifierGroup? initialGroup,
  }) : _mode = mode,
       _initialGroup = initialGroup {
    if (_mode != ModifierFormMode.create) assert(initialGroup != null);
    final group = initialGroup;
    if (group != null) {
      _loadFrom(group);
    } else {
      _selectionType = ModifierSelectionType.single;
      _priceBehavior = ModifierPriceBehavior.fixed;
      addOption();
    }

    groupNameController.addListener(notifyListeners);
    saveCommand = CommandWithParam((_) => _save());
    saveCommand.addListener(notifyListeners);
  }

  static const _uuid = Uuid();
  static const maxOptions = 10;

  final Future<void> Function(ModifierGroup group)? onSave;
  ModifierGroup? _initialGroup;

  ModifierFormMode _mode;
  ModifierFormMode get mode => _mode;

  bool get isReadOnly => _mode == ModifierFormMode.view;
  bool get isEditing => _mode == ModifierFormMode.edit;

  final groupNameController = TextEditingController();

  ModifierPriceBehavior _priceBehavior = ModifierPriceBehavior.fixed;
  ModifierPriceBehavior get priceBehavior => _priceBehavior;
  bool get hasPriceChange => _priceBehavior == ModifierPriceBehavior.fixed;

  ModifierSelectionType _selectionType = ModifierSelectionType.single;
  ModifierSelectionType get selectionType => _selectionType;

  int _defaultSelectionIndex = -1;
  int get defaultSelectionIndex => _defaultSelectionIndex;

  final List<ModifierOptionDraft> _options = [];
  List<ModifierOptionDraft> get options => List.unmodifiable(_options);

  bool get canAddOption => _options.length < maxOptions;

  late final CommandWithParam<void, void> saveCommand;

  void enterEdit() {
    if (_mode != ModifierFormMode.view) return;
    if (onSave == null) return;
    _mode = ModifierFormMode.edit;
    notifyListeners();
  }

  void cancelEdit() {
    if (_mode != ModifierFormMode.edit) return;
    final group = _initialGroup;
    if (group != null) {
      _loadFrom(group);
    }
    _mode = ModifierFormMode.view;
    notifyListeners();
  }

  void setPriceBehavior(ModifierPriceBehavior behavior) {
    if (_priceBehavior == behavior) return;
    _priceBehavior = behavior;
    if (!hasPriceChange) {
      for (final o in _options) {
        o.priceController.clear();
      }
    }
    notifyListeners();
  }

  void setSelectionType(ModifierSelectionType type) {
    if (_selectionType == type) return;
    _selectionType = type;
    notifyListeners();
  }

  void setDefaultSelectionIndex(int index) {
    if (_defaultSelectionIndex == index) return;
    _defaultSelectionIndex = index;
    notifyListeners();
  }

  void addOption() {
    if (isReadOnly) return;
    if (!canAddOption) return;
    _options.add(ModifierOptionDraft(id: _uuid.v4()));
    notifyListeners();
  }

  void removeOption(int index) {
    if (isReadOnly) return;
    if (index < 0 || index >= _options.length) return;
    _options[index].dispose();
    _options.removeAt(index);

    if (_defaultSelectionIndex == index) {
      _defaultSelectionIndex = -1;
    } else if (_defaultSelectionIndex > index) {
      _defaultSelectionIndex--;
    }

    notifyListeners();
  }

  String? validate() {
    final name = groupNameController.text.trim();
    if (name.isEmpty) return 'Group name cannot be empty.';
    if (_options.isEmpty) return 'At least one option is required.';

    for (final o in _options) {
      final label = o.labelController.text.trim();
      if (label.isEmpty) return 'Option label cannot be empty.';

      if (hasPriceChange) {
        final raw = o.priceController.text.trim();
        if (raw.isEmpty) continue; // treat empty as 0.0
        if (double.tryParse(raw) == null) return 'Invalid option price.';
      }
    }
    return null;
  }

  Future<void> save() => saveCommand.execute(null);

  Future<void> _save() async {
    if (isReadOnly) return;
    if (onSave == null) return;
    final error = validate();
    if (error != null) throw StateError(error);

    final group = _buildGroup();
    await onSave!(group);
    _initialGroup = group;
    if (_mode == ModifierFormMode.edit) {
      _mode = ModifierFormMode.view;
    }
  }

  ModifierGroup _buildGroup() {
    final name = groupNameController.text.trim();
    final selectionType = _selectionType;
    final options = <ModifierOptions>[];

    for (final o in _options) {
      final label = o.labelController.text.trim();

      double? price;
      if (hasPriceChange) {
        final raw = o.priceController.text.trim();
        if (raw.isEmpty) {
          price = 0.0;
        } else {
          price = double.tryParse(raw) ?? 0.0;
        }
      }

      options.add(
        ModifierOptions(
          id: o.id,
          name: label,
          price: hasPriceChange ? price : null,
          isDefault: _defaultSelectionIndex == options.length,
        ),
      );
    }

    return ModifierGroup(
      id: _initialGroup?.id ?? _uuid.v4(),
      name: name,
      selectionType: selectionType,
      priceBehavior: _priceBehavior,
      minSelection: 0,
      maxSelection: selectionType == ModifierSelectionType.single ? 1 : 0,
      modifierOptions: options,
    );
  }

  void _loadFrom(ModifierGroup group) {
    groupNameController.text = group.name;
    _selectionType = group.selectionType;
    _priceBehavior = group.priceBehavior;

    _options
      ..forEach((o) => o.dispose())
      ..clear();

    if (group.modifierOptions.isEmpty) {
      if (!isReadOnly) _options.add(ModifierOptionDraft(id: _uuid.v4()));
      _defaultSelectionIndex = -1;
      return;
    }

    for (final option in group.modifierOptions) {
      _options.add(
        ModifierOptionDraft(
          id: option.id,
          labelText: option.name,
          priceText: option.price?.toString() ?? '',
        ),
      );
    }

    final defaultIndex = group.modifierOptions.indexWhere((o) => o.isDefault);
    _defaultSelectionIndex = defaultIndex >= 0 ? defaultIndex : -1;

    if (!hasPriceChange) {
      for (final o in _options) {
        o.priceController.clear();
      }
    }
  }

  @override
  void dispose() {
    saveCommand.removeListener(notifyListeners);
    groupNameController.removeListener(notifyListeners);
    groupNameController.dispose();
    for (final o in _options) {
      o.dispose();
    }
    super.dispose();
  }
}

class ModifierOptionDraft {
  ModifierOptionDraft({
    required this.id,
    String? labelText,
    String? priceText,
  }) {
    if (labelText != null) labelController.text = labelText;
    if (priceText != null) priceController.text = priceText;
  }

  final String id;
  final labelController = TextEditingController();
  final priceController = TextEditingController();

  void dispose() {
    labelController.dispose();
    priceController.dispose();
  }
}
