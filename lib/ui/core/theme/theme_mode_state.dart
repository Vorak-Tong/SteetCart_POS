import 'package:flutter/material.dart';

/// App-wide theme mode state.
///
/// This intentionally uses a simple [ValueNotifier] (instead of Provider/Riverpod)
/// to match the project's state management style for tab indices.
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier<ThemeMode>(
  ThemeMode.light,
);
