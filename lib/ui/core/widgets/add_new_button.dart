import 'package:flutter/material.dart';

class AddNewButton extends StatelessWidget {
  const AddNewButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(0, 56),
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      child: const Text('Add New'),
    );
  }
}