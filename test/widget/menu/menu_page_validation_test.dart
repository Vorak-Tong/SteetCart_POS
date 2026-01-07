import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/ui/menu/widgets/menu_tab/menu_page.dart';
import 'package:street_cart_pos/ui/menu/widgets/menu_tab/product_form_page.dart';
import 'package:street_cart_pos/ui/menu/utils/product_form_route_args.dart';
import 'package:street_cart_pos/ui/menu/viewmodel/product_form_viewmodel.dart';
import '../../helpers/fake_menu_repository.dart';

void main() {
  setUp(() async {
    MenuRepository.setInstance(FakeMenuRepository());
    await MenuRepository().reset();
  });

  testWidgets('MenuPage navigates to product form', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/menu',
      routes: [
        GoRoute(
          path: '/menu',
          builder: (context, state) => const Scaffold(body: MenuPage()),
        ),
        GoRoute(
          path: '/menu/product',
          builder: (context, state) {
            final args = state.extra;
            if (args is! ProductFormRouteArgs) {
              return const Scaffold(body: Text('Missing args'));
            }
            return Scaffold(
              body: ProductFormPage(
                mode: args.mode,
                categories: args.categories,
                availableModifiers: args.availableModifiers,
                initialProduct: args.initialProduct,
                onSave: args.onSave,
              ),
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add New'));
    await tester.pumpAndSettle();

    // ProductFormPage no longer renders its own title/header; verify form UI.
    expect(find.text('Create Product'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is ProductFormPage && w.mode == ProductFormMode.create,
      ),
      findsOneWidget,
    );
  });
}
