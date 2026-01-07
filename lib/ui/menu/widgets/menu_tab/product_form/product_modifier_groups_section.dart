import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/core/widgets/product/dashed_border_painter.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/product_form_viewmodel.dart';

class ProductModifierGroupsSection extends StatelessWidget {
  const ProductModifierGroupsSection({
    super.key,
    required this.viewModel,
    required this.onOpenModifierPicker,
  });

  final ProductFormViewModel viewModel;
  final Future<void> Function() onOpenModifierPicker;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Modifier Groups',
          style: TextStyle(fontSize: 12, color: Color(0xFF393838)),
        ),
        const SizedBox(height: 8),
        ...viewModel.selectedModifiers.map(
          (modifier) => Container(
            width: double.infinity,
            height: 44,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  modifier.name,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                if (!viewModel.isReadOnly)
                  GestureDetector(
                    onTap: () => viewModel.removeModifier(modifier),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.black,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (!viewModel.isReadOnly)
          CustomPaint(
            foregroundPainter: DashedBorderPainter(
              color: const Color(0xFF696969),
              strokeWidth: 1,
              dashWidth: 4,
              dashSpace: 4,
              borderRadius: 8,
            ),
            child: InkWell(
              onTap: onOpenModifierPicker,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '+ Add Another Option',
                  style: TextStyle(fontSize: 14, color: Color(0xFF393838)),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

