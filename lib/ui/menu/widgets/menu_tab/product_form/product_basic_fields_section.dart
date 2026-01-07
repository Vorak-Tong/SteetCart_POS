import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:street_cart_pos/domain/models/product.dart';
import 'package:street_cart_pos/ui/core/widgets/forms/app_input_decoration.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/product_form_viewmodel.dart';

class ProductBasicFieldsSection extends StatelessWidget {
  const ProductBasicFieldsSection({super.key, required this.viewModel});

  final ProductFormViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(
            text: 'Item Name',
            style: TextStyle(fontSize: 12, color: Color(0xFF393838)),
            children: [
              TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: viewModel.nameController,
          maxLength: Product.nameMax,
          readOnly: viewModel.isReadOnly,
          decoration: appTextFieldDecoration(
            context,
            hintText: 'e.g., Ice Latte',
            hideCounter: false,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Description',
          style: TextStyle(fontSize: 12, color: Color(0xFF393838)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: viewModel.descriptionController,
          maxLength: Product.descriptionMax,
          readOnly: viewModel.isReadOnly,
          decoration: appTextFieldDecoration(
            context,
            hintText: 'Short description',
            hideCounter: false,
          ),
        ),
        const SizedBox(height: 20),
        const Text.rich(
          TextSpan(
            text: 'Base Price',
            style: TextStyle(fontSize: 12, color: Color(0xFF393838)),
            children: [
              TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: viewModel.priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: const [_DecimalInputFormatter()],
          readOnly: viewModel.isReadOnly,
          decoration: appTextFieldDecoration(
            context,
            hintText: '\$ 0.00',
            hideCounter: false,
          ),
        ),
      ],
    );
  }
}

class _DecimalInputFormatter extends TextInputFormatter {
  const _DecimalInputFormatter();

  static final _regex = RegExp(r'^[0-9]*\\.?[0-9]*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    if (_regex.hasMatch(newValue.text)) return newValue;
    return oldValue;
  }
}
