import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/core/widgets/add_new_button.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/modifier_viewmodel.dart';
import 'package:street_cart_pos/ui/menu/widgets/modifier_form_page.dart';
import 'package:street_cart_pos/ui/menu/widgets/modifier_item_card.dart';

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
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AddNewButton(onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModifierFormPage(
                          isEditing: false,
                          onSave: (name, count) {
                            _viewModel.addModifierGroup(name, count);
                          },
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 12),

              // Modifier List
              Expanded(
                child: ListView.separated(
                  itemCount: _viewModel.modifierGroups.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final modifier = _viewModel.modifierGroups[index];
                    return ModifierItemCard(
                      name: modifier.name,
                      optionCount: modifier.modifierOptions.length,
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ModifierFormPage(
                              isEditing: true,
                              initialName: modifier.name,
                              onSave: (name, count) {
                                _viewModel.updateModifierGroup(
                                    modifier, name, count);
                              },
                            ),
                          ),
                        );
                      },
                      onDelete: () {
                        _viewModel.deleteModifierGroup(modifier);
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