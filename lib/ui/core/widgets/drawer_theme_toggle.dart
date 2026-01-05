import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/core/theme/theme_mode_state.dart';

class DrawerThemeToggle extends StatelessWidget {
  const DrawerThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ValueListenableBuilder(
        valueListenable: appThemeMode,
        builder: (context, mode, _) {
          final isDark = mode == ThemeMode.dark;
          return SwitchListTile.adaptive(
            secondary: Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            ),
            title: const Text('Dark mode'),
            value: isDark,
            onChanged: (value) {
              appThemeMode.value = value ? ThemeMode.dark : ThemeMode.light;
            },
          );
        },
      ),
    );
  }
}
