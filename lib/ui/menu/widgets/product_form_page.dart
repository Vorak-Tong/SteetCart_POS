import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/core/widgets/dashed_border_painter.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key, required this.isEditing});

  final bool isEditing;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedCategory;

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
            const Text(
              'Item Name',
              style: TextStyle(fontSize: 12, color: Color(0xFF393838)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
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
            const Text(
              'Base Price',
              style: TextStyle(fontSize: 12, color: Color(0xFF393838)),
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
            const Text(
              'Category',
              style: TextStyle(fontSize: 12, color: Color(0xFF393838)),
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
                items: const [
                  DropdownMenuItem(value: 'Coffee', child: Text('Coffee')),
                  DropdownMenuItem(value: 'Tea', child: Text('Tea')),
                ],
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
            CustomPaint(
              painter: DashedBorderPainter(
                color: const Color(0xFF696969),
                strokeWidth: 1,
                dashWidth: 4,
                dashSpace: 4,
                borderRadius: 8,
              ),
              child: InkWell(
                onTap: () {
                  // TODO: Add modifier group logic
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECEBEB),
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
                  // TODO: Handle save
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