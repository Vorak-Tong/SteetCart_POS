import 'package:flutter/material.dart';

class FormSubmitButton extends StatelessWidget {
  const FormSubmitButton({
    super.key,
    required this.onPressed,
    required this.idleLabel,
    this.running = false,
    this.runningLabel = 'Saving...',
    this.enabled = true,
    this.height = 44,
    this.borderRadius = 8,
    this.backgroundColor = const Color(0xFF5EAF41),
    this.textStyle = const TextStyle(fontSize: 16),
  });

  final Future<void> Function() onPressed;
  final String idleLabel;
  final bool running;
  final String runningLabel;
  final bool enabled;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton(
        onPressed: enabled && !running ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Text(running ? runningLabel : idleLabel, style: textStyle),
      ),
    );
  }
}

