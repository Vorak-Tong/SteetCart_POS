import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/store_profile.dart';
import 'package:street_cart_pos/ui/policy/viewmodel/store_profile_viewmodel.dart';

class AboutStorePage extends StatefulWidget {
  const AboutStorePage({super.key});

  @override
  State<AboutStorePage> createState() => _AboutStorePageState();
}

class _AboutStorePageState extends State<AboutStorePage> {
  final StoreProfileViewModel _viewModel = StoreProfileViewModel();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _editing = false;

  @override
  void dispose() {
    _viewModel.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _syncControllers(StoreProfile profile) {
    if (_editing) return;
    _nameController.text = profile.name;
    _phoneController.text = profile.phone;
    _addressController.text = profile.address;
  }

  bool get _formValid {
    return _nameController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        _addressController.text.trim().isNotEmpty;
  }

  Future<void> _startEditing() async {
    final profile = _viewModel.profile;
    setState(() {
      _editing = true;
      _nameController.text = profile.name;
      _phoneController.text = profile.phone;
      _addressController.text = profile.address;
    });
  }

  void _cancelEditing() {
    setState(() => _editing = false);
    _syncControllers(_viewModel.profile);
  }

  Future<void> _save() async {
    if (!_formValid || _viewModel.updateProfileCommand.running) return;

    final next = StoreProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    try {
      await _viewModel.save(next);
      if (!mounted) return;
      setState(() => _editing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Store profile updated')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final theme = Theme.of(context);
        final profile = _viewModel.profile;
        _syncControllers(profile);

        final saving = _viewModel.updateProfileCommand.running;
        final loading = _viewModel.loadProfileCommand.running;

        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: const Text('About Store'),
                actions: [
                  if (_editing)
                    TextButton(
                      onPressed: saving ? null : _cancelEditing,
                      child: const Text('Cancel'),
                    )
                  else
                    IconButton(
                      tooltip: 'Edit',
                      onPressed: loading ? null : _startEditing,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  if (_editing)
                    TextButton(
                      onPressed: !_formValid || saving ? null : _save,
                      child: const Text('Save'),
                    ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Store information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            TextField(
                              controller: _nameController,
                              readOnly: !_editing,
                              showCursor: _editing,
                              maxLength: StoreProfile.nameMax,
                              decoration: InputDecoration(
                                labelText: 'Store name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onChanged: _editing
                                  ? (_) => setState(() {})
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _phoneController,
                              readOnly: !_editing,
                              showCursor: _editing,
                              maxLength: StoreProfile.phoneMax,
                              decoration: InputDecoration(
                                labelText: 'Contact number',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onChanged: _editing
                                  ? (_) => setState(() {})
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _addressController,
                              readOnly: !_editing,
                              showCursor: _editing,
                              maxLength: StoreProfile.addressMax,
                              decoration: InputDecoration(
                                labelText: 'Address',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              minLines: 2,
                              maxLines: 3,
                              onChanged: _editing
                                  ? (_) => setState(() {})
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (saving || loading)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.08),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        );
      },
    );
  }
}
