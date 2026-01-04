import 'package:flutter/material.dart';

class OrderDatePickerButton extends StatelessWidget {
  const OrderDatePickerButton({
    super.key,
    required this.date,
    required this.onPickDate,
  });

  final DateTime date;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    final label = MaterialLocalizations.of(context).formatMediumDate(date);

    return OutlinedButton.icon(
      onPressed: onPickDate,
      icon: const Icon(Icons.calendar_today_outlined, size: 18),
      label: Text(label),
    );
  }
}
