import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/category.dart';
import 'package:street_cart_pos/domain/models/modifier_group.dart';
import 'package:street_cart_pos/domain/models/product.dart';
import 'package:street_cart_pos/ui/menu/widgets/menu_tab/product_form/modifier_group_picker_sheet.dart';
import 'package:street_cart_pos/ui/menu/widgets/menu_tab/product_form/product_form.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/product_form_viewmodel.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({
    super.key,
    required this.mode,
    required this.categories,
    required this.availableModifiers,
    this.initialProduct,
    this.onSave,
  });

  final ProductFormMode mode;
  final List<Category> categories;
  final List<ModifierGroup> availableModifiers;
  final Product? initialProduct;
  final Future<void> Function(Product product)? onSave;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  late final ProductFormViewModel _viewModel = ProductFormViewModel(
    mode: widget.mode,
    categories: widget.categories,
    availableModifiers: widget.availableModifiers,
    initialProduct: widget.initialProduct,
    onSave: widget.onSave,
  );

  @override
  void initState() {
    super.initState();
    if (widget.mode != ProductFormMode.view) {
      assert(widget.onSave != null);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      await _viewModel.pickImage();
    } catch (e, st) {
      debugPrint('Image pick failed: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image pick failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submit() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _viewModel.save();
      if (!mounted) return;
      if (_viewModel.mode == ProductFormMode.create) {
        navigator.pop(true);
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('Saved')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to save: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
    }
  }

  void _toggleEdit() {
    if (_viewModel.mode == ProductFormMode.view) {
      _viewModel.enterEdit();
    } else if (_viewModel.mode == ProductFormMode.edit) {
      _viewModel.cancelEdit();
    }
  }

  Future<void> _openModifierPicker() async {
    if (_viewModel.isReadOnly) return;

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return ModifierGroupPickerSheet(
          unselected: _viewModel.unselectedModifiers,
          onSelected: (modifier) {
            _viewModel.addModifier(modifier);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  if (_viewModel.mode != ProductFormMode.create &&
                      widget.onSave != null)
                    _viewModel.mode == ProductFormMode.edit
                        ? TextButton(
                            onPressed: _toggleEdit,
                            child: const Text('Cancel'),
                          )
                        : IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Edit',
                            onPressed: _toggleEdit,
                          ),
                ],
              ),
              const SizedBox(height: 8),
              ProductForm(
                viewModel: _viewModel,
                categories: widget.categories,
                onPickImage: _pickImage,
                onOpenModifierPicker: _openModifierPicker,
                onSubmit: _submit,
              ),
            ],
          ),
        );
      },
    );
  }
}
