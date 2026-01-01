import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.currentRouteName});

  final String? currentRouteName;

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Center(
                child: Text(
                  'Street Cart POS',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.point_of_sale),
              title: const Text('Sale'),
              selected: currentRouteName == 'sale',
              onTap: () {
                Navigator.of(context).pop();
                context.goNamed('sale');
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Menu'),
              selected: currentRouteName == 'menu',
              onTap: () {
                Navigator.of(context).pop();
                context.goNamed('menu');
              },
            ),
            ListTile(
              leading: const Icon(Icons.policy),
              title: const Text('Policy'),
              selected: currentRouteName == 'policy',
              onTap: () {
                Navigator.of(context).pop();
                context.goNamed('policy');
              },
            ),
            ListTile(
              leading: const Icon(Icons.summarize),
              title: const Text('Report'),
              selected: currentRouteName == 'report',
              onTap: () {
                Navigator.of(context).pop();
                context.goNamed('report');
              },
            ),
          ],
        ),
      );
  }
}
