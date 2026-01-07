import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/core/widgets/forms/form_submit_button.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/product_form_viewmodel.dart';

class ProductFormSubmitButton extends StatelessWidget {
  const ProductFormSubmitButton({
    super.key,
    required this.viewModel,
    required this.onSubmit,
  });

  final ProductFormViewModel viewModel;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    if (viewModel.isReadOnly) return const SizedBox.shrink();

    return FormSubmitButton(
      onPressed: onSubmit,
      enabled: viewModel.canSave,
      running: viewModel.saveCommand.running,
      idleLabel: viewModel.isEditing ? 'Save' : 'Create Product',
    );
  }
}
