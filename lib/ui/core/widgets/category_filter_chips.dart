import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';

class CategoryChipItem {
  const CategoryChipItem({required this.id, required this.label});

  final String id;
  final String label;
}

class CategoryFilterChips extends StatelessWidget {
  const CategoryFilterChips({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.allCategoryId = '__all__',
    this.allLabel = 'All',
    this.height = 44,
    this.trailingChips = const [],
  });

  final List<Category> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onCategorySelected;

  final String allCategoryId;
  final String allLabel;
  final double height;
  final List<CategoryChipItem> trailingChips;

  @override
  Widget build(BuildContext context) {
    final items = <CategoryChipItem>[
      CategoryChipItem(id: allCategoryId, label: allLabel),
      ...categories.map((c) => CategoryChipItem(id: c.id, label: c.name)),
      ...trailingChips,
    ];

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = items[index];

          return ChoiceChip(
            label: Text(item.label),
            selected: selectedCategoryId == item.id,
            onSelected: (_) => onCategorySelected(item.id),
          );
        },
      ),
    );
  }
}
