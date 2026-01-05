import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import 'package:street_cart_pos/ui/core/widgets/dashed_border_painter.dart';
import 'package:street_cart_pos/ui/core/utils/local_file_image.dart';
import 'package:street_cart_pos/ui/core/utils/persist_image_path.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({
    super.key,
    required this.isEditing,
    required this.categories,
    required this.availableModifiers,
    this.initialProduct,
    required this.onSave,
  });

  final bool isEditing;
  final List<Category> categories;
  final List<ModifierGroup> availableModifiers;
  final Product? initialProduct;
  final Future<void> Function(Product product) onSave;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedCategoryId;
  final List<ModifierGroup> _selectedModifiers = [];
  String? _imagePath;
  bool _saving = false;

  bool get _priceValid {
    final value = double.tryParse(_priceController.text.trim());
    return value != null && value > 0;
  }

  bool get _formValid => _nameController.text.trim().isNotEmpty && _priceValid;

  @override
  void initState() {
    super.initState();

    final product = widget.initialProduct;
    if (product == null) return;

    _nameController.text = product.name;
    _descriptionController.text = product.description ?? '';
    _priceController.text = product.basePrice.toString();
    _selectedCategoryId = product.category?.id;
    _imagePath = product.imagePath;

    final selectedIds = product.modifierGroups.map((g) => g.id).toSet();
    _selectedModifiers.addAll(
      widget.availableModifiers.where((m) => selectedIds.contains(m.id)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (!mounted) return;
      if (picked == null) return;

      final persistedPath = await persistImagePath(picked.path);
      if (!mounted) return;
      setState(() => _imagePath = persistedPath);
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
    if (!_formValid || _saving) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) return;

    Category? category;
    if (_selectedCategoryId != null) {
      for (final c in widget.categories) {
        if (c.id == _selectedCategoryId) {
          category = c;
          break;
        }
      }
    }

    final initial = widget.initialProduct;
    final product = Product(
      id: initial?.id,
      name: name,
      description: description.isEmpty ? null : description,
      basePrice: price,
      category: category,
      modifierGroups: List.unmodifiable(_selectedModifiers),
      imagePath: _imagePath,
      isActive: initial?.isActive ?? true,
    );

    setState(() => _saving = true);
    try {
      await widget.onSave(product);
      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _imagePath != null;
    final imageProvider = _imagePath == null
        ? null
        : localFileImageProvider(_imagePath!);
    final Widget imageContent;
    if (_imagePath == null) {
      imageContent = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.image_outlined, size: 40, color: Color(0xFFCBCBCB)),
          SizedBox(height: 8),
          Text(
            'Upload Image',
            style: TextStyle(fontSize: 12, color: Color(0xFFCBCBCB)),
          ),
        ],
      );
    } else if (imageProvider != null) {
      imageContent = Image(image: imageProvider, fit: BoxFit.cover);
    } else if (kIsWeb) {
      imageContent = Image.network(_imagePath!, fit: BoxFit.cover);
    } else {
      imageContent = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.image_outlined, size: 40, color: Color(0xFFCBCBCB)),
          SizedBox(height: 8),
          Text(
            'Unsupported image',
            style: TextStyle(fontSize: 12, color: Color(0xFFCBCBCB)),
          ),
        ],
      );
    }

    final Widget imageBody = hasImage
        ? Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(child: imageContent),
              Positioned(
                top: 6,
                right: 6,
                child: Material(
                  color: Colors.black.withOpacity(0.35),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => setState(() => _imagePath = null),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  color: Colors.black.withOpacity(0.35),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_outlined, size: 14, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'Tap to change',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        : imageContent;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEditing ? 'Edit Product' : 'Add New Product',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Upload
            Center(
              child: CustomPaint(
                painter: DashedBorderPainter(
                  color: const Color(0xFFCBCBCB),
                  strokeWidth: 1,
                  dashWidth: 4,
                  dashSpace: 4,
                  borderRadius: 12,
                ),
                child: InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 160,
                    height: 149,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageBody,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Item Name
            const Text.rich(
              TextSpan(
                text: 'Item Name',
                style: TextStyle(fontSize: 12, color: Color(0xFF393838)),
                children: [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              maxLength: 20,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'e.g., Ice Latte',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFCBCBCB),
                ),
                filled: true,
                fillColor: const Color(0xFFF7F7F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Description
            const Text(
              'Description',
              style: TextStyle(fontSize: 12, color: Color(0xFF393838)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLength: 80,
              decoration: InputDecoration(
                hintText: 'Short description',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFCBCBCB),
                ),
                filled: true,
                fillColor: const Color(0xFFF7F7F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Base Price
            const Text.rich(
              TextSpan(
                text: 'Base Price',
                style: TextStyle(fontSize: 12, color: Color(0xFF393838)),
                children: [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: const [_DecimalInputFormatter()],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '\$ 0.00',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFCBCBCB),
                ),
                filled: true,
                fillColor: const Color(0xFFF7F7F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category
            const Text(
              'Category (Optional)',
              style: TextStyle(fontSize: 12, color: Color(0xFF393838)),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: DropdownButtonFormField<String?>(
                value: _selectedCategoryId,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(8),
                hint: const Text(
                  'Select category',
                  style: TextStyle(fontSize: 14, color: Color(0xFFCBCBCB)),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF7F7F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Uncategorized'),
                  ),
                  ...widget.categories.map((category) {
                    return DropdownMenuItem<String?>(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }),
                ],
                onChanged: (val) => setState(() => _selectedCategoryId = val),
              ),
            ),
            const SizedBox(height: 20),

            // Modifier Groups
            const Text(
              'Modifier Groups',
              style: TextStyle(fontSize: 12, color: Color(0xFF393838)),
            ),
            const SizedBox(height: 8),

            // Selected Modifiers List
            ..._selectedModifiers.map(
              (modifier) => Container(
                width: double.infinity,
                height: 44,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      modifier.name,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() => _selectedModifiers.remove(modifier));
                      },
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            CustomPaint(
              foregroundPainter: DashedBorderPainter(
                color: const Color(0xFF696969),
                strokeWidth: 1,
                dashWidth: 4,
                dashSpace: 4,
                borderRadius: 8,
              ),
              child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      final unselectedModifiers = widget.availableModifiers
                          .where((m) => !_selectedModifiers.contains(m))
                          .toList();

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
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (unselectedModifiers.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(
                                      child: Text(
                                        'No more modifiers available.',
                                      ),
                                    ),
                                  )
                                else
                                  ...unselectedModifiers.map(
                                    (modifier) => ListTile(
                                      title: Text(modifier.name),
                                      onTap: () {
                                        setState(
                                          () =>
                                              _selectedModifiers.add(modifier),
                                        );
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '+ Add Another Option',
                    style: TextStyle(fontSize: 14, color: Color(0xFF393838)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Create Item Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton(
                onPressed: _formValid && !_saving ? _submit : null,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF5EAF41),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _saving
                      ? 'Saving...'
                      : (widget.isEditing ? 'Save' : 'Create Product'),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _DecimalInputFormatter extends TextInputFormatter {
  const _DecimalInputFormatter();

  static final _regex = RegExp(r'^[0-9]*\.?[0-9]*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    if (_regex.hasMatch(newValue.text)) return newValue;
    return oldValue;
  }
}
