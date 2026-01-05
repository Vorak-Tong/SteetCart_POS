import 'package:flutter/material.dart';

class EditValueDialog extends StatefulWidget {
  const EditValueDialog({
    super.key,
    required this.title,
    required this.initialValue,
    required this.suffix,
    this.helperText,
    this.validator,
  });

  final String title;
  final String initialValue;
  final String suffix;
  final String? helperText;
  final String? Function(String?)? validator;

  @override
  State<EditValueDialog> createState() => _EditValueDialogState();
}

class _EditValueDialogState extends State<EditValueDialog> {
  late String _currentValue;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          initialValue: _currentValue,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            suffixText: widget.suffix,
            helperText: widget.helperText,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          validator: widget.validator,
          onChanged: (value) => _currentValue = value,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _currentValue);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}