import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import 'package:street_cart_pos/ui/menu/widgets/modifier_tab/modifier_form_page.dart';

class ModifierDetailPage extends StatefulWidget {
  const ModifierDetailPage({
    super.key,
    required this.group,
    required this.onUpdate,
  });

  final ModifierGroup group;
  final Future<void> Function(ModifierGroup group) onUpdate;

  @override
  State<ModifierDetailPage> createState() => _ModifierDetailPageState();
}

class _ModifierDetailPageState extends State<ModifierDetailPage> {
  late ModifierGroup _group = widget.group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier Group'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ModifierFormPage(
                    initialGroup: _group,
                    onSave: (updated) async {
                      await widget.onUpdate(updated);
                      if (mounted) {
                        setState(() => _group = updated);
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _group.name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Selection type',
            value: switch (_group.selectionType) {
              ModifierSelectionType.single => 'Single selection',
              ModifierSelectionType.multi => 'Multi selection',
            },
          ),
          const SizedBox(height: 6),
          _InfoRow(
            label: 'Price behavior',
            value: switch (_group.priceBehavior) {
              ModifierPriceBehavior.fixed => 'Price change',
              ModifierPriceBehavior.none => 'No price change',
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Options',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          if (_group.modifierOptions.isEmpty)
            Text(
              'No options',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            ..._group.modifierOptions.map(
              (option) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(option.name),
                subtitle: option.isDefault ? const Text('Default') : null,
                trailing: _group.priceBehavior == ModifierPriceBehavior.none
                    ? null
                    : Text(
                        option.price == null ? '—' : '+ \$${option.price}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
