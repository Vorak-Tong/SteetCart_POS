import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/core/widgets/add_new_button.dart';
import 'package:street_cart_pos/ui/menu/widgets/modifier_form_page.dart';
import 'package:street_cart_pos/ui/menu/widgets/modifier_item_card.dart';

// Mock model for local use
class ModifierGroupMock {
  final String name;
  final int optionCount;

  ModifierGroupMock({required this.name, required this.optionCount});
}

class ModifierPage extends StatefulWidget {
  const ModifierPage({super.key});

  @override
  State<ModifierPage> createState() => _ModifierPageState();
}

class _ModifierPageState extends State<ModifierPage> {
  late List<ModifierGroupMock> _modifiers;

  @override
  void initState() {
    super.initState();
    _modifiers = _getMockModifiers();
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
                    hintText: 'Search modifiers',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                        setState(() {
                          _modifiers.add(
                            ModifierGroupMock(name: name, optionCount: count),
                          );
                        });
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
              itemCount: _modifiers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final modifier = _modifiers[index];
                return ModifierItemCard(
                  name: modifier.name,
                  optionCount: modifier.optionCount,
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModifierFormPage(
                          isEditing: true,
                          initialName: modifier.name,
                          onSave: (name, count) {
                            setState(() {
                              _modifiers[index] =
                                  ModifierGroupMock(name: name, optionCount: count);
                            });
                          },
                        ),
                      ),
                    );
                  },
                  onDelete: () {
                    setState(() => _modifiers.removeAt(index));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<ModifierGroupMock> _getMockModifiers() {
    return [
      ModifierGroupMock(name: 'Ice Level', optionCount: 4),
      ModifierGroupMock(name: 'Sugar Level', optionCount: 5),
      ModifierGroupMock(name: 'Size Level', optionCount: 3),
    ];
  }
}