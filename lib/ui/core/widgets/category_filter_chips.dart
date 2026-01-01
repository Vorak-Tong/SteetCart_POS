import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';

class CategoryFilterChips extends StatelessWidget {
  const CategoryFilterChips({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.allCategoryId = '__all__',
    this.allLabel = 'All',
    this.height = 44,
  });

  final List<Category> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onCategorySelected;

  final String allCategoryId;
  final String allLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 1 + categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final id = isAll ? allCategoryId : categories[index - 1].id;
          final label = isAll ? allLabel : categories[index - 1].name;

          return ChoiceChip(
            label: Text(label),
            selected: selectedCategoryId == id,
            onSelected: (_) => onCategorySelected(id),
          );
        },
      ),
    );
  }
}

