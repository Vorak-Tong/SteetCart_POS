import 'package:flutter/material.dart';

class PrinterSettingsPage extends StatelessWidget {
  const PrinterSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Printer')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Bluetooth printing is not supported on this platform.'),
      ),
    );
  }
}
