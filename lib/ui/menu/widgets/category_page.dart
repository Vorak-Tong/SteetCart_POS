import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import 'package:street_cart_pos/ui/core/widgets/add_new_button.dart';
import 'package:street_cart_pos/ui/menu/widgets/category_form_modal.dart';
import 'package:street_cart_pos/ui/menu/widgets/category_item_card.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late List<Category> _categories;

  @override
  void initState() {
    super.initState();
    _categories = _getMockCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          // Search Bar + Add New Button
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search categories',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              AddNewButton(onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => CategoryFormModal(
                    isEditing: false,
                    onSave: (name, isActive) {
                      setState(() {
                        _categories.add(Category(name: name));
                      });
                    },
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),
          
          // Category List (Static for Stage 1)
          Expanded(
            child: ListView.separated(
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                return CategoryItemCard(
                  name: category.name,
                  itemCount: 0, // Mock count
                  onEdit: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => CategoryFormModal(
                        isEditing: true,
                        categoryName: category.name,
                        onSave: (name, isActive) {
                          setState(() {
                            // Update the specific item in the list
                            _categories[index] = Category(name: name);
                          });
                        },
                      ),
                    );
                  },
                  onDelete: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Category> _getMockCategories() {
    return [
      Category(name: 'Coffee'),
      Category(name: 'Tea'),
      Category(name: 'Smoothies'),
      Category(name: 'Dessert'),
    ];
  }
}
