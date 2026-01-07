import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/modifier_enums.dart';
import 'package:street_cart_pos/ui/core/widgets/forms/app_input_decoration.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/modifier_form_viewmodel.dart';

class ModifierBehaviorFieldsSection extends StatelessWidget {
  const ModifierBehaviorFieldsSection({super.key, required this.viewModel});

  final ModifierFormViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final isReadOnly = viewModel.isReadOnly;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price Behavior',
          style: TextStyle(fontSize: 10, color: Color(0xFF393838)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: DropdownButtonFormField<ModifierPriceBehavior>(
            initialValue: viewModel.priceBehavior,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(8),
            hint: Text(
              'Select',
              style: TextStyle(fontSize: 14, color: appFormHintColor(context)),
            ),
            decoration: appDropdownDecoration(context),
            items: const [
              DropdownMenuItem(
                value: ModifierPriceBehavior.fixed,
                child: Text('Price Change'),
              ),
              DropdownMenuItem(
                value: ModifierPriceBehavior.none,
                child: Text('No Price Change'),
              ),
            ],
            onChanged: isReadOnly
                ? null
                : (val) {
                    if (val == null) return;
                    viewModel.setPriceBehavior(val);
                  },
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Selection Type',
          style: TextStyle(fontSize: 10, color: Color(0xFF393838)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: DropdownButtonFormField<ModifierSelectionType>(
            initialValue: viewModel.selectionType,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(8),
            hint: Text(
              'Select',
              style: TextStyle(fontSize: 14, color: appFormHintColor(context)),
            ),
            decoration: appDropdownDecoration(context),
            items: const [
              DropdownMenuItem(
                value: ModifierSelectionType.single,
                child: Text('Single Selection'),
              ),
              DropdownMenuItem(
                value: ModifierSelectionType.multi,
                child: Text('Multi Selection'),
              ),
            ],
            onChanged: isReadOnly
                ? null
                : (val) {
                    if (val == null) return;
                    viewModel.setSelectionType(val);
                  },
          ),
        ),
      ],
    );
  }
}
