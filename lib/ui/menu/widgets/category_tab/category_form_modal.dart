import 'package:flutter/material.dart';

class CategoryFormModal extends StatefulWidget {
  const CategoryFormModal({
    super.key,
    this.categoryName,
    required this.isEditing,
    required this.onSave,
  });

  final String? categoryName;
  final bool isEditing;
  final void Function(String name) onSave;

  @override
  State<CategoryFormModal> createState() => _CategoryFormModalState();
}

class _CategoryFormModalState extends State<CategoryFormModal> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.categoryName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isEditing ? 'Edit Category' : 'Create Category',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.black),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.black),

          // Form Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Name Label
                  const Text(
                    'Category Name',
                    style: TextStyle(fontSize: 12, color: Color(0xFF393838)),
                  ),
                  const SizedBox(height: 8),
                  // Input Field
                  TextField(
                    controller: _nameController,
                    maxLength: 15,
                    decoration: InputDecoration(
                      hintText: 'e.g., Coffee',
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
                  const Spacer(),

                  // Save Button (Added to ensure functionality)
                  Center(
                    child: SizedBox(
                      width: 361,
                      height: 44,
                      child: FilledButton(
                        onPressed: () {
                          if (_nameController.text.trim().isNotEmpty) {
                            widget.onSave(_nameController.text.trim());
                            Navigator.pop(context);
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF5EAF41),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
