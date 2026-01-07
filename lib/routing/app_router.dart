import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:street_cart_pos/ui/core/widgets/navigation/app_shell.dart';
import 'package:street_cart_pos/ui/core/widgets/navigation/bottom_nav_generator.dart';
import 'package:street_cart_pos/ui/menu/utils/menu_tab_state.dart';
import 'package:street_cart_pos/ui/menu/utils/modifier_form_route_args.dart';
import 'package:street_cart_pos/ui/menu/widgets/menu_tab/product_form_page.dart';
import 'package:street_cart_pos/ui/menu/utils/product_form_route_args.dart';
import 'package:street_cart_pos/ui/menu/widgets/menu_tab_selector.dart';
import 'package:street_cart_pos/ui/menu/widgets/modifier_tab/modifier_form_page.dart';
import 'package:street_cart_pos/ui/policy/policy_page.dart';
import 'package:street_cart_pos/ui/report/widgets/report_page.dart';
import 'package:street_cart_pos/ui/sale/widgets/sale_tab_selector.dart';
import 'package:street_cart_pos/ui/sale/utils/sale_tab_state.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/sale',
  routes: <RouteBase>[
    ShellRoute(
      builder: (context, state, child) {
        final routeKey = _routeKeyFor(state);
        final shouldShowBottomNav = _shouldShowBottomNavFor(state);

        return AppShell(
          title: _titleWidgetForRoute(routeKey),
          currentRouteName: routeKey,
          bottomNavigationBar:
              shouldShowBottomNav ? _bottomNavigator(routeKey) : null,
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
          path: '/menu/product',
          name: 'productForm',
          builder: (context, state) {
            final args = state.extra;
            if (args is! ProductFormRouteArgs) {
              return const Center(child: Text('Missing product route args.'));
            }
            return ProductFormPage(
              mode: args.mode,
              categories: args.categories,
              availableModifiers: args.availableModifiers,
              initialProduct: args.initialProduct,
              onSave: args.onSave,
            );
          },
        ),
        GoRoute(
          path: '/menu/modifier',
          name: 'modifierForm',
          builder: (context, state) {
            final args = state.extra;
            if (args is! ModifierFormRouteArgs) {
              return const Center(child: Text('Missing modifier route args.'));
            }
            return ModifierFormPage(
              mode: args.mode,
              initialGroup: args.initialGroup,
              onSave: args.onSave,
            );
          },
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
  final path = state.uri.path;
  if (path.startsWith('/sale')) return 'sale';
  if (path.startsWith('/menu')) return 'menu';
  if (path.startsWith('/policy')) return 'policy';
  if (path.startsWith('/report')) return 'report';
  return '';
}

bool _shouldShowBottomNavFor(GoRouterState state) {
  switch (state.uri.path) {
    case '/sale':
    case '/menu':
      return true;
    default:
      return false;
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
