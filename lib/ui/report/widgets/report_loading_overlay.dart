import 'package:flutter/material.dart';

class ReportLoadingOverlay extends StatelessWidget {
  const ReportLoadingOverlay({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.black.withOpacity(0.1),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
