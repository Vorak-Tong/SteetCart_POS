import 'package:street_cart_pos/data/repositories/menu_repository.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import 'package:uuid/uuid.dart';

Future<void> seedLongTextMenu() async {
  String cap(String value, int max) =>
      value.length <= max ? value : value.substring(0, max);

  final repo = MenuRepository();
  await repo.init();

  final uuid = Uuid();

  final longCategory = Category(
    id: uuid.v4(),
    // Keep within business rules; "long" here means close to limits.
    name: cap('Tea Specials 2025', Category.nameMax),
  );
  await repo.addCategory(longCategory);

  final sugar = ModifierGroup(
    id: uuid.v4(),
    name: cap('Sugar Level (One)', ModifierGroup.nameMax),
    selectionType: ModifierSelectionType.single,
    priceBehavior: ModifierPriceBehavior.none,
    modifierOptions: [
      ModifierOptions(name: cap('No sugar (0%)', ModifierOptions.nameMax)),
      ModifierOptions(name: cap('Less sugar (25%)', ModifierOptions.nameMax)),
      ModifierOptions(name: cap('Normal sugar (50%)', ModifierOptions.nameMax)),
      ModifierOptions(name: cap('More sugar (75%)', ModifierOptions.nameMax)),
    ],
  );

  final size = ModifierGroup(
    id: uuid.v4(),
    name: cap('Size (Cup Volume)', ModifierGroup.nameMax),
    selectionType: ModifierSelectionType.single,
    priceBehavior: ModifierPriceBehavior.fixed,
    modifierOptions: [
      ModifierOptions(
        name: cap('Small (12oz)', ModifierOptions.nameMax),
        price: 0,
      ),
      ModifierOptions(
        name: cap('Medium (16oz)', ModifierOptions.nameMax),
        price: 0.5,
      ),
      ModifierOptions(
        name: cap('Large (22oz)', ModifierOptions.nameMax),
        price: 0.75,
      ),
    ],
  );

  await repo.addModifierGroup(sugar);
  await repo.addModifierGroup(size);

  final longProduct = Product(
    id: uuid.v4(),
    name: cap('Iced Matcha Latte', Product.nameMax),
    description: cap('Smooth iced matcha latte.', Product.descriptionMax),
    basePrice: 2.5,
    category: longCategory,
    modifierGroups: [sugar, size],
  );

  await repo.addProduct(longProduct);
}
