import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:street_cart_pos/ui/core/widgets/forms/add_new_button.dart';
import 'package:street_cart_pos/ui/core/widgets/feedback/inline_hint_card.dart';
import 'package:street_cart_pos/ui/core/widgets/feedback/swipe_action_background.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/modifier_viewmodel.dart';
import 'package:street_cart_pos/ui/menu/utils/modifier_form_route_args.dart';
import 'package:street_cart_pos/ui/menu/widgets/modifier_tab/modifier_item_card.dart';

class ModifierPage extends StatefulWidget {
  const ModifierPage({super.key});

  @override
  State<ModifierPage> createState() => _ModifierPageState();
}

class _ModifierPageState extends State<ModifierPage> {
  late final ModifierViewModel _viewModel = ModifierViewModel();

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
                        hintText: 'Search modifiers',
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
                      _openCreateModifier(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Modifier List
              Expanded(
                child: _viewModel.modifierGroups.isEmpty
                    ? InlineHintCard(
                        message:
                            'No modifier groups yet. Add modifiers like Sugar Level or Size.',
                        actionLabel: 'Add',
                        onAction: () => _openCreateModifier(context),
                      )
                    : ListView.separated(
                        itemCount: _viewModel.modifierGroups.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final modifier = _viewModel.modifierGroups[index];
                          return Dismissible(
                            key: ValueKey(modifier.id),
                            direction: DismissDirection.endToStart,
                            background: const SizedBox.shrink(),
                            secondaryBackground: const SwipeActionBackground(
                              alignment: Alignment.centerRight,
                              backgroundColor: Color(0xFFFFEBEB),
                              borderRadius: 10,
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
                                      title: const Text(
                                        'Delete modifier group?',
                                      ),
                                      content: const Text(
                                        'This will permanently delete the modifier group and its options, and remove it from any products using it.',
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
                                await _viewModel.deleteModifierGroup(modifier);
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
                            child: ModifierItemCard(
                              name: modifier.name,
                              optionCount: modifier.modifierOptions.length,
                              onTap: () {
                                context.push(
                                  '/menu/modifier',
                                  extra: ModifierFormRouteArgs(
                                    mode: ModifierFormMode.view,
                                    initialGroup: modifier,
                                    onSave: _viewModel.updateModifierGroup,
                                  ),
                                );
                              },
                              onEdit: () {
                                context.push(
                                  '/menu/modifier',
                                  extra: ModifierFormRouteArgs(
                                    mode: ModifierFormMode.edit,
                                    initialGroup: modifier,
                                    onSave: _viewModel.updateModifierGroup,
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

  void _openCreateModifier(BuildContext context) {
    context.push(
      '/menu/modifier',
      extra: ModifierFormRouteArgs(
        mode: ModifierFormMode.create,
        onSave: _viewModel.addModifierGroup,
      ),
    );
  }
}
