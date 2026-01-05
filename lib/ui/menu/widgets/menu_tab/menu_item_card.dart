import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import 'package:street_cart_pos/ui/core/utils/number_format.dart';
import 'package:street_cart_pos/ui/core/widgets/product_image.dart';

class MenuItemCard extends StatelessWidget {
  const MenuItemCard({super.key, required this.product, this.onTap});

  final Product product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 95,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // First Section
                Expanded(
                  child: SizedBox(
                    height: 75,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Title
                        Text(
                          product.name,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Modifiers
                        Text(
                          product.modifierGroups.isNotEmpty
                              ? product.modifierGroups
                                    .map((g) => g.name)
                                    .join(', ')
                              : 'No Modifiers',
                          style: const TextStyle(
                            color: Color(0xFFCBCBCB),
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Category Chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.category?.name ?? 'Uncategorized',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        // Base Price
                        Text(
                          'Base Price: ${formatUsd(product.basePrice)}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Second Section
                SizedBox(
                  width: 60,
                  height: 60,
                  child: ProductImage(
                    imagePath: product.imagePath,
                    borderRadius: 8,
                    placeholderColor: const Color(0xFFCBCBCB),
                    showPlaceholderLabel: false,
                    placeholderIconSize: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
