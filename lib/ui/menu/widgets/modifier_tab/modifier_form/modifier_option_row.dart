import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/modifier_option.dart';
import 'package:street_cart_pos/ui/core/widgets/forms/app_input_decoration.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/modifier_form_viewmodel.dart';

class ModifierOptionRow extends StatelessWidget {
  const ModifierOptionRow({
    super.key,
    required this.viewModel,
    required this.index,
  });

  final ModifierFormViewModel viewModel;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isReadOnly = viewModel.isReadOnly;
    final hasPriceChange = viewModel.hasPriceChange;
    final option = viewModel.options[index];

    return Row(
      children: [
        if (!isReadOnly)
          GestureDetector(
            onTap: () => viewModel.removeOption(index),
            child: const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.close,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
        Expanded(
          child: SizedBox(
            height: 44,
            child: TextField(
              controller: option.labelController,
              maxLength: ModifierOptions.nameMax,
              readOnly: isReadOnly,
              decoration: appTextFieldDecoration(
                context,
                hintText: 'Option Label',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ),
        if (hasPriceChange) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            height: 44,
            child: TextField(
              controller: option.priceController,
              readOnly: isReadOnly,
              decoration: appTextFieldDecoration(
                context,
                hintText: '+ \$ 0.00',
                hideCounter: false,
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: appFormHintColor(context),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ],
        const SizedBox(width: 8),
        Radio<int>(
          value: index,
          activeColor: const Color(0xFF5EAF41),
        ),
      ],
    );
  }
}
