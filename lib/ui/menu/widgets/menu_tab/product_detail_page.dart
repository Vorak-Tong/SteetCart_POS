import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import 'package:street_cart_pos/ui/core/utils/number_format.dart';
import 'package:street_cart_pos/ui/core/widgets/product_image.dart';
import 'package:street_cart_pos/ui/menu/widgets/menu_tab/product_form_page.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({
    super.key,
    required this.product,
    required this.categories,
    required this.availableModifiers,
    required this.onUpdate,
  });

  final Product product;
  final List<Category> categories;
  final List<ModifierGroup> availableModifiers;
  final Future<void> Function(Product product) onUpdate;

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
        title: const Text(
          'Item Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductFormPage(
                    isEditing: true,
                    initialProduct: product,
                    categories: categories,
                    availableModifiers: availableModifiers,
                    onSave: onUpdate,
                  ),
                ),
              );
              if (!context.mounted) return;
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Center(
              child: SizedBox(
                width: 160,
                height: 149,
                child: ProductImage(
                  imagePath: product.imagePath,
                  borderRadius: 12,
                  showPlaceholderLabel: false,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Item Name
            _buildReadOnlyField('Item Name', product.name),
            const SizedBox(height: 20),

            // Description
            _buildReadOnlyField('Description', product.description ?? ''),
            const SizedBox(height: 20),

            // Base Price
            _buildReadOnlyField('Base Price', formatUsd(product.basePrice)),
            const SizedBox(height: 20),

            // Category
            _buildReadOnlyField(
              'Category',
              product.category?.name ?? 'Uncategorized',
            ),
            const SizedBox(height: 20),

            // Modifier Groups
            const Text(
              'Modifier Groups',
              style: TextStyle(fontSize: 12, color: Color(0xFF393838)),
            ),
            const SizedBox(height: 8),
            if (product.modifierGroups.isEmpty)
              const Text(
                'No modifier groups',
                style: TextStyle(fontSize: 14, color: Color(0xFFCBCBCB)),
              )
            else
              ...product.modifierGroups.map(
                (group) => Container(
                  width: 357,
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
                        group.name,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '${group.modifierOptions.length} options',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF393838)),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
