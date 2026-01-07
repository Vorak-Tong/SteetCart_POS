import 'package:flutter/material.dart';

const Color _lightModeFieldFill = Color.fromARGB(255, 239, 239, 239);

Color appFormFieldFillColor(BuildContext context) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;

  if (theme.brightness == Brightness.dark) {
    return scheme.surfaceContainerHighest;
  }

  return _lightModeFieldFill;
}

Color appFormHintColor(BuildContext context) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;

  if (theme.brightness == Brightness.dark) {
    return scheme.onSurfaceVariant.withValues(alpha: 0.75);
  }

  return const Color(0xFFCBCBCB);
}

InputDecoration appTextFieldDecoration(
  BuildContext context, {
  required String hintText,
  bool hideCounter = true,
  EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  ),
  TextStyle? hintStyle,
}) {
  final scheme = Theme.of(context).colorScheme;

  final effectiveHintStyle =
      hintStyle ??
      TextStyle(
        fontSize: 14,
        color: appFormHintColor(context),
      );

  return InputDecoration(
    hintText: hintText,
    hintStyle: effectiveHintStyle,
    counterText: hideCounter ? '' : null,
    filled: true,
    fillColor: appFormFieldFillColor(context),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: scheme.outline, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: scheme.primary, width: 1.2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: scheme.outline, width: 1),
    ),
    contentPadding: contentPadding,
  );
}

InputDecoration appDropdownDecoration(
  BuildContext context, {
  EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(horizontal: 16),
}) {
  final scheme = Theme.of(context).colorScheme;

  return InputDecoration(
    filled: true,
    fillColor: appFormFieldFillColor(context),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: scheme.outline, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: scheme.primary, width: 1.2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: scheme.outline, width: 1),
    ),
    contentPadding: contentPadding,
  );
}

