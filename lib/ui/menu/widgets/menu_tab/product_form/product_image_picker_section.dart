import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/core/utils/local_file_image.dart';
import 'package:street_cart_pos/ui/core/widgets/product/dashed_border_painter.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/product_form_viewmodel.dart';

class ProductImagePickerSection extends StatelessWidget {
  const ProductImagePickerSection({
    super.key,
    required this.viewModel,
    required this.onPickImage,
  });

  final ProductFormViewModel viewModel;
  final Future<void> Function() onPickImage;

  @override
  Widget build(BuildContext context) {
    final hasImage = viewModel.hasImage;
    final path = viewModel.imagePath;

    final imageProvider = path == null ? null : localFileImageProvider(path);

    final Widget imageContent;
    if (path == null || path.trim().isEmpty) {
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
      imageContent = Image.network(path, fit: BoxFit.cover);
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
              if (!viewModel.isReadOnly)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: viewModel.clearImage,
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              if (!viewModel.isReadOnly)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    color: Colors.black.withValues(alpha: 0.35),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Tap to change',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          )
        : imageContent;

    return Center(
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: const Color(0xFFCBCBCB),
          strokeWidth: 1,
          dashWidth: 4,
          dashSpace: 4,
          borderRadius: 12,
        ),
        child: InkWell(
          onTap: viewModel.isReadOnly ? null : onPickImage,
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
    );
  }
}

