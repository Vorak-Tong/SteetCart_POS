import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:street_cart_pos/data/local/app_database.dart';
import 'package:street_cart_pos/data/local/dao/category_dao.dart';
import 'package:street_cart_pos/data/local/dao/product_dao.dart';
import 'package:street_cart_pos/data/repositories/category_repository.dart';
import 'package:street_cart_pos/data/repositories/order_repository.dart';
import 'package:street_cart_pos/data/repositories/product_repository.dart';
import 'package:street_cart_pos/data/repositories/sale_policy_repository.dart';
import 'package:street_cart_pos/domain/models/enums.dart';
import 'package:street_cart_pos/domain/models/order_model.dart';
import 'package:street_cart_pos/domain/models/product_model.dart';
import 'package:street_cart_pos/domain/models/sale_policy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // 1. Initialize FFI for desktop/unit testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUpAll(() {
    // 2. Mock path_provider because AppDatabase uses getApplicationSupportDirectory
    // We redirect it to use the current directory ('.') for tests.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return '.';
      },
    );
  });

  setUp(() async {
    // Ensure we start with a clean database for each test
    await AppDatabase.reset();
  });

  tearDown(() async {
    // Close connection after test
    await AppDatabase.close();
  });

  group('Database & DAO Tests', () {
    test('CategoryDao CRUD operations', () async {
      final categoryDao = CategoryDao();

      // INSERT
      final catId = 'cat_1';
      await categoryDao.insert({
        CategoryDao.colId: catId,
        CategoryDao.colName: 'Drinks',
      });

      // READ
      final result = await categoryDao.getById(catId);
      expect(result, isNotNull);
      expect(result![CategoryDao.colName], 'Drinks');

      // UPDATE
      await categoryDao.update({
        CategoryDao.colId: catId,
        CategoryDao.colName: 'Beverages',
      });
      final updated = await categoryDao.getById(catId);
      expect(updated![CategoryDao.colName], 'Beverages');

      // DELETE
      await categoryDao.delete(catId);
      final deleted = await categoryDao.getById(catId);
      expect(deleted, isNull);
    });

    test('ProductDao Foreign Key Constraints', () async {
      final categoryDao = CategoryDao();
      final productDao = ProductDao();

      // 1. Create a Category
      final catId = 'cat_test';
      await categoryDao.insert({
        CategoryDao.colId: catId,
        CategoryDao.colName: 'Test Category',
      });

      // 2. Create a Product linked to that Category
      final prodId = 'prod_1';
      await productDao.insert({
        ProductDao.colId: prodId,
        ProductDao.colName: 'Coffee',
        ProductDao.colBasePrice: 2.5,
        ProductDao.colCategoryId: catId,
      });

      // Verify Product exists
      final product = await productDao.getById(prodId);
      expect(product, isNotNull);
      expect(product![ProductDao.colCategoryId], catId);

      // 3. Test ON DELETE SET NULL
      // If we delete the category, the product's category_id should become NULL
      // (Because we defined ON DELETE SET NULL in AppDatabase)
      await categoryDao.delete(catId);

      final productAfterCatDelete = await productDao.getById(prodId);
      expect(productAfterCatDelete![ProductDao.colCategoryId], isNull);
    });

    test('AppDatabase singleton returns same instance', () async {
      final db1 = await AppDatabase.instance();
      final db2 = await AppDatabase.instance();
      expect(db1, equals(db2));
    });
  });

  group('Repository Integration Tests', () {
    test('ProductRepository: Full Lifecycle (Create, Read, Update w/ Modifiers)', () async {
      final repo = ProductRepository();
      final categoryRepo = CategoryRepository();

      // 1. Create Category
      final category = Category(name: 'Food');
      await categoryRepo.saveCategory(category);

      // 2. Create Product with Modifiers
      final modifierOption = ModifierOptions(name: 'Extra Cheese', price: 0.5);
      final modifierGroup = ModifierGroup(
        name: 'Toppings',
        modifierOptions: [modifierOption],
      );
      
      final product = Product(
        name: 'Burger',
        basePrice: 5.0,
        category: category,
        modifierGroups: [modifierGroup],
      );

      await repo.createProduct(product);

      // 3. Verify Save
      final products = await repo.getProducts();
      expect(products.length, 1);
      final savedProduct = products.first;
      expect(savedProduct.name, 'Burger');
      expect(savedProduct.category?.name, 'Food');
      expect(savedProduct.modifierGroups.length, 1);
      expect(savedProduct.modifierGroups.first.modifierOptions.first.name, 'Extra Cheese');

      // 4. Update Product (Change name and remove modifiers)
      final updatedProduct = Product(
        id: product.id,
        name: 'Cheeseburger', // Changed name
        basePrice: 6.0,
        category: category,
        modifierGroups: [], // Removed modifiers
      );
      await repo.updateProduct(updatedProduct);

      // 5. Verify Update
      final productsAfterUpdate = await repo.getProducts();
      expect(productsAfterUpdate.first.name, 'Cheeseburger');
      expect(productsAfterUpdate.first.modifierGroups, isEmpty);
    });

    test('OrderRepository: Create and Fetch Order with Items and Payment', () async {
      final productRepo = ProductRepository();
      final orderRepo = OrderRepository();

      // Setup: Create a product to sell
      final product = Product(name: 'Coffee', basePrice: 2.0);
      await productRepo.createProduct(product);

      // 1. Create Order
      final orderItem = OrderProduct(quantity: 2, product: product);
      final payment = Payment(
        type: PaymentMethod.cash,
        recieveAmountKHR: 0,
        recieveAmountUSD: 5.0,
        changeKhr: 0,
        changeUSD: 1.0,
      );

      final order = Order(
        timeStamp: DateTime.now(),
        orderType: OrderType.dineIn,
        paymentType: PaymentMethod.cash,
        status: SaleStatus.finalized,
        orderProducts: [orderItem],
        payment: payment,
      );

      await orderRepo.createOrder(order);

      // 2. Fetch and Verify
      final orders = await orderRepo.getOrders();
      expect(orders.length, 1);
      
      final savedOrder = orders.first;
      expect(savedOrder.orderProducts.length, 1);
      expect(savedOrder.orderProducts.first.product?.name, 'Coffee');
      expect(savedOrder.payment?.recieveAmountUSD, 5.0);
    });

    test('SalePolicyRepository: Get Default and Update', () async {
      final repo = SalePolicyRepository();

      // 1. Update Policy
      final newPolicy = SalePolicy(vatPercent: 10, usdToKhrRate: 4100);
      await repo.savePolicy(newPolicy);

      // 2. Verify
      final fetchedPolicy = await repo.getPolicy();
      expect(fetchedPolicy.vatPercent, 10);
      expect(fetchedPolicy.usdToKhrRate, 4100);
    });
  });
}