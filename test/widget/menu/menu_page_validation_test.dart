import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/ui/menu/widgets/menu_tab/menu_page.dart';
import '../../helpers/fake_menu_repository.dart';

void main() {
  setUp(() async {
    MenuRepository.setInstance(FakeMenuRepository());
    await MenuRepository().reset();
  });

  testWidgets('MenuPage navigates to product form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MenuPage())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.text('Add New'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Add New Product'), findsOneWidget);
  });
}
