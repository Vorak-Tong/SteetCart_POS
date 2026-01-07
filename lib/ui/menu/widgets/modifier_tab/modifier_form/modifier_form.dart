import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/modifier_form_viewmodel.dart';
import 'package:street_cart_pos/ui/menu/widgets/modifier_tab/modifier_form/modifier_add_option_section.dart';
import 'package:street_cart_pos/ui/menu/widgets/modifier_tab/modifier_form/modifier_behavior_fields_section.dart';
import 'package:street_cart_pos/ui/menu/widgets/modifier_tab/modifier_form/modifier_group_name_field.dart';
import 'package:street_cart_pos/ui/menu/widgets/modifier_tab/modifier_form/modifier_options_section.dart';
import 'package:street_cart_pos/ui/menu/widgets/modifier_tab/modifier_form/modifier_submit_button.dart';

class ModifierForm extends StatelessWidget {
  const ModifierForm({
    super.key,
    required this.viewModel,
    required this.onSubmit,
  });

  final ModifierFormViewModel viewModel;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final isReadOnly = viewModel.isReadOnly;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModifierGroupNameField(viewModel: viewModel),
        const SizedBox(height: 20),
        ModifierBehaviorFieldsSection(viewModel: viewModel),
        const SizedBox(height: 24),
        ModifierOptionsSection(viewModel: viewModel),
        const SizedBox(height: 20),
        if (!isReadOnly) ...[
          ModifierAddOptionSection(viewModel: viewModel),
          const SizedBox(height: 40),
          ModifierSubmitButton(viewModel: viewModel, onSubmit: onSubmit),
        ],
        const SizedBox(height: 20),
      ],
    );
  }
}

