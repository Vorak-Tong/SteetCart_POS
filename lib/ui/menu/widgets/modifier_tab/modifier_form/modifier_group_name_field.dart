import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/modifier_group.dart';
import 'package:street_cart_pos/ui/core/widgets/forms/app_input_decoration.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/modifier_form_viewmodel.dart';

class ModifierGroupNameField extends StatelessWidget {
  const ModifierGroupNameField({super.key, required this.viewModel});

  final ModifierFormViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Group Name',
          style: TextStyle(fontSize: 10, color: Color(0xFF393838)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: viewModel.groupNameController,
          maxLength: ModifierGroup.nameMax,
          readOnly: viewModel.isReadOnly,
          decoration: appTextFieldDecoration(
            context,
            hintText: 'e.g. Size',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ],
    );
  }
}
