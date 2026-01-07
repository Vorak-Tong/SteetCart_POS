import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/category.dart';
import 'package:street_cart_pos/ui/core/widgets/forms/app_input_decoration.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/product_form_viewmodel.dart';

class ProductCategoryField extends StatelessWidget {
  const ProductCategoryField({
    super.key,
    required this.viewModel,
    required this.categories,
  });

  final ProductFormViewModel viewModel;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category (Optional)',
          style: TextStyle(fontSize: 12, color: Color(0xFF393838)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: DropdownButtonFormField<String?>(
            initialValue: viewModel.selectedCategoryId,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(8),
            hint: Text(
              'Select category',
              style: TextStyle(fontSize: 14, color: appFormHintColor(context)),
            ),
            decoration: appDropdownDecoration(context),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Uncategorized'),
              ),
              ...categories.map(
                (category) => DropdownMenuItem<String?>(
                  value: category.id,
                  child: Text(category.name),
                ),
              ),
            ],
            onChanged:
                viewModel.isReadOnly ? null : viewModel.setSelectedCategoryId,
          ),
        ),
      ],
    );
  }
}
