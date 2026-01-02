import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:street_cart_pos/ui/core/widgets/app_shell.dart';
import 'package:street_cart_pos/ui/core/widgets/bottom_nav_generator.dart';
import 'package:street_cart_pos/ui/menu/menu_tab_state.dart';
import 'package:street_cart_pos/ui/menu/widgets/menu_tab_selector.dart';
import 'package:street_cart_pos/ui/policy/polic_page.dart';
import 'package:street_cart_pos/ui/report/widgets/report_page.dart';
import 'package:street_cart_pos/ui/sale/widgets/sale_tab_selector.dart';
import 'package:street_cart_pos/ui/sale/sale_tab_state.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/sale',
  routes: <RouteBase>[
    ShellRoute(
      builder: (context, state, child) {
        final routeKey = _routeKeyFor(state);

        return AppShell(
          title: _titleWidgetForRoute(routeKey),
          currentRouteName: routeKey,
          bottomNavigationBar: _bottomNavigator(routeKey),
          child: child,
        );
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/sale',
          name: 'sale',
          builder: (context, state) => const SaleTabSelector(),
        ),
        GoRoute(
          path: '/menu',
          name: 'menu',
          builder: (context, state) => const MenuTabSelector(),
        ),
         GoRoute(
          path: '/report',
          name: 'report',
          builder: (context, state) => const ReportPage(),
        ),
        GoRoute(
          path: '/policy',
          name: 'policy',
          builder: (context, state) => const PolicyPage(),
        ),
      ],
    ),
  ],
);

String _routeKeyFor(GoRouterState state) {
  switch (state.uri.path) {
    case '/sale':
      return 'sale';
    case '/menu':
      return 'menu';
    case '/policy':
      return 'policy';
    case '/report':
      return 'report';
    default:
      return '';
  }
}

Widget _titleWidgetForRoute(String routeKey) {
  switch (routeKey) {
    case 'sale':
      return const Text('Sale');
    case 'menu':
      return ValueListenableBuilder(
        valueListenable: menuTabIndex,
        builder: (context, index, _) {
          const titles = ['Menu Management', 'Category', 'Modifier'];
          return Text(titles[index]);
        },
      );
    case 'policy':
      return const Text('Policy');
    case 'report':
      return const Text('Report');
    default:
      return const Text('Street Cart POS');
  }
}

Widget? _bottomNavigator(String routeKey) {
  switch (routeKey) {
    case 'sale':
      return ValueListenableBuilder<int>(
        valueListenable: saleTabIndex,
        builder: (context, index, _) {
          return BottomNavGenerator(
            tabSet: FeatureTabSet.sale,
            currentIndex: index,
            onTap: (i) => saleTabIndex.value = i,
          );
        },
      );
    case 'menu':
      return ValueListenableBuilder<int>(
        valueListenable: menuTabIndex,
        builder: (context, index, _) {
          return BottomNavGenerator(
            tabSet: FeatureTabSet.menu,
            currentIndex: index,
            onTap: (i) => menuTabIndex.value = i,
          );
        },
      );
    default:
      return null;
  }
}