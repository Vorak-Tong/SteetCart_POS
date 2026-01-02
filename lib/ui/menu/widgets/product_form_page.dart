import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import 'package:street_cart_pos/ui/core/widgets/dashed_border_painter.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({
    super.key,
    required this.isEditing,
    required this.onSave,
    required this.categories,
    required this.availableModifiers,
  });

  final bool isEditing;
  final List<Category> categories;
  final List<ModifierGroup> availableModifiers;
  final void Function(
      String name, String description, double price, String category, List<ModifierGroup> modifiers) onSave;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedCategory;
  final List<ModifierGroup> _selectedModifiers = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          widget.isEditing ? 'Edit Item' : 'Add New Item',
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
                child: Container(
                  width: 160,
                  height: 149,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.image_outlined, size: 40, color: Color(0xFFCBCBCB)),
                      SizedBox(height: 8),
                      Text(
                        'Upload Image',
                        style: TextStyle(fontSize: 12, color: Color(0xFFCBCBCB)),
                      ),
                    ],
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
              decoration: InputDecoration(
                hintText: 'e.g., Ice Latte',
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFCBCBCB)),
                filled: true,
                fillColor: const Color(0xFFF7F7F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              decoration: InputDecoration(
                hintText: 'Short description',
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFCBCBCB)),
                filled: true,
                fillColor: const Color(0xFFF7F7F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '\$ 0.00',
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFCBCBCB)),
                filled: true,
                fillColor: const Color(0xFFF7F7F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),

            // Category
            const Text.rich(
              TextSpan(
                text: 'Category',
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
            SizedBox(
              height: 44,
              child: DropdownButtonFormField<String>(
                value: _selectedCategory,
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
                items: widget.categories.map((category) {
                  return DropdownMenuItem(
                    value: category.name,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
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
            ..._selectedModifiers.map((modifier) => Container(
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
                        child: const Icon(Icons.close, size: 18, color: Colors.black),
                      ),
                    ],
                  ),
                )),

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

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Select Modifier Group',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            if (unselectedModifiers.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('No more modifiers available.'),
                              )
                            else
                              ...unselectedModifiers.map((modifier) => ListTile(
                                    title: Text(modifier.name),
                                    onTap: () {
                                      setState(() => _selectedModifiers.add(modifier));
                                      Navigator.pop(context);
                                    },
                                  )),
                          ],
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF393838),
                    ),
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
                onPressed: () {
                  final name = _nameController.text.trim();
                  final priceStr = _priceController.text.trim();
                  final category = _selectedCategory;

                  if (name.isEmpty || priceStr.isEmpty || category == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all required fields (*).'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final price = double.tryParse(priceStr);
                  if (price == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid price.')),
                    );
                    return;
                  }

                  widget.onSave(name, _descriptionController.text.trim(), price, category, _selectedModifiers);
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF5EAF41),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  widget.isEditing ? 'Save' : 'Create Item',
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