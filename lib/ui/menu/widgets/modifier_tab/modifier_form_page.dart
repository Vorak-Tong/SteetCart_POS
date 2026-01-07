import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/modifier_group.dart';
import 'package:street_cart_pos/ui/menu/utils/modifier_form_route_args.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/modifier_form_viewmodel.dart';
import 'package:street_cart_pos/ui/menu/widgets/modifier_tab/modifier_form/modifier_form.dart';
import 'package:street_cart_pos/ui/menu/widgets/modifier_tab/modifier_form/modifier_form_header.dart';

class ModifierFormPage extends StatefulWidget {
  const ModifierFormPage({
    super.key,
    required this.mode,
    this.initialGroup,
    this.onSave,
  });

  final ModifierFormMode mode;
  final ModifierGroup? initialGroup;
  final Future<void> Function(ModifierGroup group)? onSave;

  @override
  State<ModifierFormPage> createState() => _ModifierFormPageState();
}

class _ModifierFormPageState extends State<ModifierFormPage> {
  late final ModifierFormViewModel _viewModel = ModifierFormViewModel(
    mode: widget.mode,
    initialGroup: widget.initialGroup,
    onSave: widget.onSave,
  );

  @override
  void initState() {
    super.initState();
    if (widget.mode != ModifierFormMode.view) {
      assert(widget.onSave != null);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (_viewModel.mode == ModifierFormMode.view) {
      _viewModel.enterEdit();
    } else if (_viewModel.mode == ModifierFormMode.edit) {
      _viewModel.cancelEdit();
    }
  }

  Future<void> _submit() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await _viewModel.save();
      if (!mounted) return;
      if (_viewModel.mode == ModifierFormMode.create) {
        navigator.pop(true);
      } else {
        messenger.showSnackBar(const SnackBar(content: Text('Saved')));
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(e is StateError ? e.message : 'Failed to save: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ModifierFormHeader(
                mode: _viewModel.mode,
                onClose: () => Navigator.pop(context),
                onToggleEdit: _toggleEdit,
              ),
              const SizedBox(height: 8),
              ModifierForm(viewModel: _viewModel, onSubmit: _submit),
            ],
          ),
        );
      },
    );
  }
}
