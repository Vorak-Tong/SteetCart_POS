import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import 'package:uuid/uuid.dart';

Future<void> seedMenuForSaleFlows() async {
  final repo = MenuRepository();
  await repo.init();

  final uuid = Uuid();

  final tea = Category(id: uuid.v4(), name: 'Tea');
  final coffee = Category(id: uuid.v4(), name: 'Coffee');
  await repo.addCategory(tea);
  await repo.addCategory(coffee);

  final sugar = ModifierGroup(
    id: uuid.v4(),
    name: 'Sugar',
    selectionType: ModifierSelectionType.single,
    priceBehavior: ModifierPriceBehavior.none,
    modifierOptions: [
      ModifierOptions(name: 'No sugar'),
      ModifierOptions(name: 'Less sugar'),
      ModifierOptions(name: 'Normal sugar'),
      ModifierOptions(name: 'More sugar'),
    ],
  );

  final size = ModifierGroup(
    id: uuid.v4(),
    name: 'Size',
    selectionType: ModifierSelectionType.single,
    priceBehavior: ModifierPriceBehavior.fixed,
    modifierOptions: [
      ModifierOptions(name: 'Small', price: 0),
      ModifierOptions(name: 'Medium', price: 0.5),
      ModifierOptions(name: 'Large', price: 0.75),
    ],
  );

  await repo.addModifierGroup(sugar);
  await repo.addModifierGroup(size);

  final icedLatte = Product(
    id: uuid.v4(),
    name: 'Iced Latte',
    basePrice: 2.0,
    category: coffee,
    modifierGroups: const [],
  );

  final icedMatcha = Product(
    id: uuid.v4(),
    name: 'Iced Matcha Latte',
    basePrice: 2.5,
    category: tea,
    modifierGroups: [sugar, size],
  );

  await repo.addProduct(icedLatte);
  await repo.addProduct(icedMatcha);
}

