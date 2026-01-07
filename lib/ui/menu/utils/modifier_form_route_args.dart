import 'package:street_cart_pos/domain/models/modifier_group.dart';

enum ModifierFormMode { create, view, edit }

class ModifierFormRouteArgs {
  const ModifierFormRouteArgs({
    required this.mode,
    this.initialGroup,
    this.onSave,
  });

  final ModifierFormMode mode;
  final ModifierGroup? initialGroup;
  final Future<void> Function(ModifierGroup group)? onSave;
}

