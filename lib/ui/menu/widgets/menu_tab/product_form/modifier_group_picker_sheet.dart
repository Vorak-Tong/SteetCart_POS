import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/modifier_group.dart';

class ModifierGroupPickerSheet extends StatelessWidget {
  const ModifierGroupPickerSheet({
    super.key,
    required this.unselected,
    required this.onSelected,
  });

  final List<ModifierGroup> unselected;
  final ValueChanged<ModifierGroup> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Text(
                  'Select Modifier Group',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              if (unselected.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('No more modifiers available.')),
                )
              else
                for (final modifier in unselected)
                  ListTile(
                    title: Text(modifier.name),
                    onTap: () => onSelected(modifier),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

