import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/core/widgets/forms/form_submit_button.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/modifier_form_viewmodel.dart';

class ModifierSubmitButton extends StatelessWidget {
  const ModifierSubmitButton({
    super.key,
    required this.viewModel,
    required this.onSubmit,
  });

  final ModifierFormViewModel viewModel;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return FormSubmitButton(
      onPressed: onSubmit,
      enabled: true,
      running: viewModel.saveCommand.running,
      idleLabel: viewModel.isEditing ? 'Save' : 'Create',
    );
  }
}
