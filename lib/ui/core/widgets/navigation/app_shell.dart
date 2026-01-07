import 'package:flutter/material.dart';

import 'package:street_cart_pos/ui/core/widgets/navigation/app_drawer.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.title,
    required this.child,
    this.bottomNavigationBar,
    this.currentRouteName,
    this.showAppBar = true,
    this.showDrawer = true,
  });

  final Widget title;
  final Widget child;
  final Widget? bottomNavigationBar;
  final String? currentRouteName;
  final bool showAppBar;
  final bool showDrawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: title) ,
      drawer: AppDrawer(currentRouteName: currentRouteName),
      drawerEnableOpenDragGesture: showDrawer,
      body: child,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
