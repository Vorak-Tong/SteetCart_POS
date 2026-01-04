import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/core/widgets/add_new_button.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/category_viewmodel.dart';
import 'package:street_cart_pos/ui/menu/widgets/category_form_modal.dart';
import 'package:street_cart_pos/ui/menu/widgets/category_item_card.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late final CategoryViewModel _viewModel = CategoryViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
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
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
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
                          _viewModel.addCategory(name, isActive);
                        },
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 12),

              // Category List
              Expanded(
                child: ListView.separated(
                  itemCount: _viewModel.categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final category = _viewModel.categories[index];
                    return CategoryItemCard(
                      name: category.name,
                      itemCount: _viewModel.getProductCountForCategory(category.id),
                      onEdit: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => CategoryFormModal(
                            isEditing: true,
                            categoryName: category.name,
                            isActive: category.isActive,
                            onSave: (name, isActive) {
                              _viewModel.updateCategory(
                                  category, name, isActive);
                            },
                          ),
                        );
                      },
                      onDelete: () {
                        _viewModel.deleteCategory(category);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
