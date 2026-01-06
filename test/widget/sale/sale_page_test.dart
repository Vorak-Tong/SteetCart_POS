import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/domain/models/category.dart';
import 'package:street_cart_pos/domain/models/product.dart';
import 'package:street_cart_pos/ui/core/theme/app_theme.dart';
import 'package:street_cart_pos/ui/sale/viewmodel/sale_viewmodel.dart';
import 'package:street_cart_pos/ui/sale/widgets/sale_tab/sale_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SalePage', () {
    late SaleViewModel viewModel;

    setUp(() {
      final beverages = Category(id: 'c-bev', name: 'Beverages');
      final sides = Category(id: 'c-sides', name: 'Sides');
      final mains = Category(id: 'c-mains', name: 'Mains');

      final products = <Product>[
        Product(
          id: 'p-soda',
          name: 'Soda Can',
          basePrice: 1.0,
          category: beverages,
        ),
        Product(
          id: 'p-iced-tea',
          name: 'Iced Tea',
          basePrice: 1.5,
          category: beverages,
        ),
        Product(
          id: 'p-chicken-rice',
          name: 'Chicken Over Rice',
          basePrice: 4.0,
          category: mains,
        ),
        Product(
          id: 'p-lamb-rice',
          name: 'Lamb Over Rice',
          basePrice: 5.0,
          category: mains,
        ),
        Product(
          id: 'p-falafel',
          name: 'Falafel Wrap',
          basePrice: 3.5,
          category: mains,
        ),
        Product(id: 'p-fries', name: 'Fries', basePrice: 2.0, category: sides),
        Product(
          id: 'p-extra-sauce',
          name: 'Extra White Sauce',
          basePrice: 0.5,
          category: sides,
        ),
      ];

      viewModel = SaleViewModel(repository: _FakeMenuRepository(products));
    });

    tearDown(() {
      viewModel.dispose();
    });

    Future<void> pumpSalePage(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(body: SalePage(viewModel: viewModel)),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
    }

    testWidgets('filters products by category chip', (tester) async {
      await pumpSalePage(tester);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Beverages'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('Soda Can'), findsOneWidget);
      expect(find.text('Iced Tea'), findsOneWidget);
      expect(find.text('Chicken Over Rice'), findsNothing);
      expect(find.text('Fries'), findsNothing);
    });

    testWidgets('filters products by search query', (tester) async {
      await pumpSalePage(tester);

      await tester.enterText(find.byType(TextField).first, 'rice');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('Chicken Over Rice'), findsOneWidget);
      expect(find.text('Lamb Over Rice'), findsOneWidget);

      expect(find.text('Falafel Wrap'), findsNothing);
      expect(find.text('Soda Can'), findsNothing);
    });

    testWidgets('combines category chip + search query', (tester) async {
      await pumpSalePage(tester);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Sides'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      await tester.enterText(find.byType(TextField).first, 'sauce');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('Extra White Sauce'), findsOneWidget);
      expect(find.text('Fries'), findsNothing);
      expect(find.text('Chicken Over Rice'), findsNothing);
    });

    testWidgets('opens selection page when tapping a product', (tester) async {
      await pumpSalePage(tester);

      await tester.tap(find.text('Chicken Over Rice'));
      await tester.pumpAndSettle();

      expect(find.text('Add to cart'), findsOneWidget);
    });
  });
}

class _FakeMenuRepository extends MenuRepository {
  _FakeMenuRepository(this._products) : super.testing();

  final List<Product> _products;

  @override
  Future<void> init() async {}

  @override
  List<Product> get products => _products;
}
