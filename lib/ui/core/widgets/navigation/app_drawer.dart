import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:street_cart_pos/ui/core/widgets/devtools/database_viewer_page.dart';
import 'package:street_cart_pos/ui/core/widgets/navigation/drawer_theme_toggle.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.currentRouteName});

  final String? currentRouteName;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                const _AppDrawerHeader(),
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
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.storage),
                  title: const Text('Database Viewer'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DatabaseViewerPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const DrawerThemeToggle(),
        ],
      ),
    );
  }
}

class _AppDrawerHeader extends StatelessWidget {
  const _AppDrawerHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final background =
        theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface;
    final foreground =
        theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface;

    return SizedBox(
      height: topInset + kToolbarHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(color: background),
        child: Padding(
          padding: EdgeInsets.only(top: topInset),
          child: SizedBox(
            height: kToolbarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/street_cart_pos.png',
                      width: 28,
                      height: 28,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Street Cart POS',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
