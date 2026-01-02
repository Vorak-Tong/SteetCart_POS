import 'package:flutter/material.dart';

import 'package:street_cart_pos/ui/core/widgets/app_drawer.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.title,
    required this.child,
    this.bottomNavigationBar,
    this.currentRouteName,
  });

  final Widget title;
  final Widget child;
  final Widget? bottomNavigationBar;
  final String? currentRouteName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title,
      ),
      drawer: AppDrawer(currentRouteName: currentRouteName),
      body: child,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
