import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import 'package:street_cart_pos/ui/core/widgets/dashed_border_painter.dart';
import 'package:street_cart_pos/ui/core/utils/number_format.dart';

class MenuItemCard extends StatelessWidget {
  const MenuItemCard({super.key, required this.product, this.onTap});

  final Product product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 357,
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
                SizedBox(
                  width: 276,
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
                const Spacer(),
                // Second Section
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CustomPaint(
                    painter: DashedBorderPainter(
                      color: const Color(0xFFCBCBCB),
                      strokeWidth: 1,
                      dashWidth: 4,
                      dashSpace: 2,
                      borderRadius: 8,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: Color(0xFFCBCBCB),
                        size: 24,
                      ),
                    ),
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
