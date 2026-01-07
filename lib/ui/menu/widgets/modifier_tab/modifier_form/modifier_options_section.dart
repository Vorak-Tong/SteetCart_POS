import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/modifier_form_viewmodel.dart';
import 'package:street_cart_pos/ui/menu/widgets/modifier_tab/modifier_form/modifier_option_row.dart';

class ModifierOptionsSection extends StatelessWidget {
  const ModifierOptionsSection({super.key, required this.viewModel});

  final ModifierFormViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final isReadOnly = viewModel.isReadOnly;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Options',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Text(
              'Select as default',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AbsorbPointer(
          absorbing: isReadOnly,
          child: RadioGroup<int>(
            groupValue: viewModel.defaultSelectionIndex,
            onChanged: (val) => viewModel.setDefaultSelectionIndex(val ?? -1),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'None',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    Radio<int>(
                      value: -1,
                      activeColor: Color(0xFF5EAF41),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: viewModel.options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => ModifierOptionRow(
                    viewModel: viewModel,
                    index: index,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

