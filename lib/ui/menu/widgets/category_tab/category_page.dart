import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/core/widgets/forms/add_new_button.dart';
import 'package:street_cart_pos/ui/core/widgets/feedback/inline_hint_card.dart';
import 'package:street_cart_pos/ui/core/widgets/feedback/swipe_action_background.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/category_viewmodel.dart';
import 'package:street_cart_pos/ui/menu/widgets/category_tab/category_form_modal.dart';
import 'package:street_cart_pos/ui/menu/widgets/category_tab/category_item_card.dart';

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
        if (_viewModel.loading && !_viewModel.hasLoadedOnce) {
          return const Center(child: CircularProgressIndicator());
        }

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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AddNewButton(
                    onPressed: () {
                      _openCreateCategory(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Category List
              Expanded(
                child: _viewModel.categories.isEmpty
                    ? InlineHintCard(
                        message:
                            'No categories yet. Add categories to organize your products.',
                        actionLabel: 'Add',
                        onAction: () => _openCreateCategory(context),
                      )
                    : ListView.separated(
                        itemCount: _viewModel.categories.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final category = _viewModel.categories[index];
                          return Dismissible(
                            key: ValueKey(category.id),
                            direction: DismissDirection.endToStart,
                            background: const SizedBox.shrink(),
                            secondaryBackground: const SwipeActionBackground(
                              alignment: Alignment.centerRight,
                              backgroundColor: Color(0xFFFFEBEB),
                              borderRadius: 12,
                              icon: Icons.delete_outline,
                              iconColor: Colors.red,
                              label: 'Delete',
                            ),
                            confirmDismiss: (direction) async {
                              if (direction != DismissDirection.endToStart) {
                                return false;
                              }
                              return await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete category?'),
                                      content: const Text(
                                        'This will permanently delete the category. Products in this category will become Uncategorized.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;
                            },
                            onDismissed: (_) async {
                              try {
                                await _viewModel.deleteCategory(category);
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to delete: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: CategoryItemCard(
                              name: category.name,
                              itemCount: _viewModel.getProductCountForCategory(
                                category.id,
                              ),
                              onEdit: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) => CategoryFormModal(
                                    isEditing: true,
                                    categoryName: category.name,
                                    onSave: (name) {
                                      _viewModel.updateCategory(category, name);
                                    },
                                  ),
                                );
                              },
                            ),
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

  void _openCreateCategory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CategoryFormModal(
        isEditing: false,
        onSave: (name) {
          _viewModel.addCategory(name);
        },
      ),
    );
  }
}
