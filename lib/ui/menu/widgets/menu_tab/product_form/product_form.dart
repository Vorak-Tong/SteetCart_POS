import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/category.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/product_form_viewmodel.dart';
import 'package:street_cart_pos/ui/menu/widgets/menu_tab/product_form/product_basic_fields_section.dart';
import 'package:street_cart_pos/ui/menu/widgets/menu_tab/product_form/product_category_field.dart';
import 'package:street_cart_pos/ui/menu/widgets/menu_tab/product_form/product_form_submit_button.dart';
import 'package:street_cart_pos/ui/menu/widgets/menu_tab/product_form/product_image_picker_section.dart';
import 'package:street_cart_pos/ui/menu/widgets/menu_tab/product_form/product_modifier_groups_section.dart';

class ProductForm extends StatelessWidget {
  const ProductForm({
    super.key,
    required this.viewModel,
    required this.categories,
    required this.onPickImage,
    required this.onOpenModifierPicker,
    required this.onSubmit,
  });

  final ProductFormViewModel viewModel;
  final List<Category> categories;
  final Future<void> Function() onPickImage;
  final Future<void> Function() onOpenModifierPicker;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProductImagePickerSection(viewModel: viewModel, onPickImage: onPickImage),
        const SizedBox(height: 24),
        ProductBasicFieldsSection(viewModel: viewModel),
        const SizedBox(height: 20),
        ProductCategoryField(viewModel: viewModel, categories: categories),
        const SizedBox(height: 20),
        ProductModifierGroupsSection(
          viewModel: viewModel,
          onOpenModifierPicker: onOpenModifierPicker,
        ),
        const SizedBox(height: 40),
        ProductFormSubmitButton(viewModel: viewModel, onSubmit: onSubmit),
        const SizedBox(height: 20),
      ],
    );
  }
}

