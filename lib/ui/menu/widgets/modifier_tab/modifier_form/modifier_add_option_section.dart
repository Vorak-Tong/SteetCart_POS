import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/core/widgets/product/dashed_border_painter.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/modifier_form_viewmodel.dart';

class ModifierAddOptionSection extends StatelessWidget {
  const ModifierAddOptionSection({super.key, required this.viewModel});

  final ModifierFormViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomPaint(
          foregroundPainter: DashedBorderPainter(
            color: const Color(0xFF696969),
            strokeWidth: 1,
            dashWidth: 4,
            dashSpace: 4,
            borderRadius: 8,
          ),
          child: InkWell(
            onTap: viewModel.canAddOption ? viewModel.addOption : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                viewModel.canAddOption
                    ? '+ Add Another Option'
                    : 'Option limit reached',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF393838),
                ),
              ),
            ),
          ),
        ),
        if (!viewModel.canAddOption) ...[
          const SizedBox(height: 8),
          Text(
            'Maximum ${ModifierFormViewModel.maxOptions} options per modifier group.',
            style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
          ),
        ],
      ],
    );
  }
}

