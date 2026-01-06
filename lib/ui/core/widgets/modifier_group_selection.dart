import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/modifier_enums.dart';
import 'package:street_cart_pos/domain/models/modifier_group.dart';
import 'package:street_cart_pos/domain/models/modifier_option.dart';
import 'package:street_cart_pos/ui/core/utils/number_format.dart';

class ModifierGroupSelection extends StatelessWidget {
  ModifierGroupSelection({
    super.key,
    required this.group,
    required this.selectedOptionIds,
    required this.readOnly,
    this.onSelectSingle,
    this.onToggleMulti,
  }) : assert(
         readOnly ||
             (group.selectionType == ModifierSelectionType.single
                 ? onSelectSingle != null
                 : onToggleMulti != null),
       );

  final ModifierGroup group;
  final Set<String> selectedOptionIds;
  final bool readOnly;

  final ValueChanged<String>? onSelectSingle;
  final void Function(String optionId, bool selected)? onToggleMulti;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                group.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final option in group.modifierOptions)
              if (group.selectionType == ModifierSelectionType.single)
                _SingleSelectionRow(
                  value: option.id,
                  groupValue: selectedOptionIds.isEmpty
                      ? null
                      : selectedOptionIds.first,
                  readOnly: readOnly,
                  title: _optionLabel(option, group.priceBehavior),
                  onChanged: onSelectSingle,
                )
              else
                _MultiSelectionRow(
                  optionId: option.id,
                  selected: selectedOptionIds.contains(option.id),
                  readOnly: readOnly,
                  title: _optionLabel(option, group.priceBehavior),
                  enabled: _isMultiOptionEnabled(
                    group: group,
                    selectedOptionIds: selectedOptionIds,
                    optionId: option.id,
                    readOnly: readOnly,
                  ),
                  onChanged: onToggleMulti,
                ),
          ],
        ),
      ),
    );
  }
}

class _SingleSelectionRow extends StatelessWidget {
  const _SingleSelectionRow({
    required this.value,
    required this.groupValue,
    required this.readOnly,
    required this.title,
    required this.onChanged,
  });

  final String value;
  final String? groupValue;
  final bool readOnly;
  final String title;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      value: value,
      groupValue: groupValue,
      onChanged: readOnly ? null : (v) => v == null ? null : onChanged?.call(v),
      title: Text(title),
      dense: true,
    );
  }
}

class _MultiSelectionRow extends StatelessWidget {
  const _MultiSelectionRow({
    required this.optionId,
    required this.selected,
    required this.readOnly,
    required this.title,
    required this.enabled,
    required this.onChanged,
  });

  final String optionId;
  final bool selected;
  final bool readOnly;
  final String title;
  final bool enabled;
  final void Function(String optionId, bool selected)? onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: selected,
      onChanged: (!enabled || readOnly)
          ? null
          : (v) => v == null ? null : onChanged?.call(optionId, v),
      title: Text(title),
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

String _optionLabel(ModifierOptions option, ModifierPriceBehavior behavior) {
  if (behavior == ModifierPriceBehavior.none) {
    return option.name;
  }

  final price = option.price ?? 0;
  if (price == 0) {
    return option.name;
  }

  final sign = price > 0 ? '+' : '-';
  final amount = formatDecimalWithThousandsSeparator(
    price.abs(),
    fractionDigits: 2,
  );
  return '${option.name} ($sign\$$amount)';
}

bool _isMultiOptionEnabled({
  required ModifierGroup group,
  required Set<String> selectedOptionIds,
  required String optionId,
  required bool readOnly,
}) {
  if (readOnly) {
    return false;
  }

  final max = group.maxSelection;
  final hasMax = max > 0;
  if (!hasMax) {
    return true;
  }

  if (selectedOptionIds.contains(optionId)) {
    return true;
  }

  return selectedOptionIds.length < max;
}
