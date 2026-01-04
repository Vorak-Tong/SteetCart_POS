import 'package:flutter_test/flutter_test.dart';
import 'package:street_cart_pos/data/local/dao/category_dao.dart';
import 'package:street_cart_pos/data/local/dao/product_dao.dart';
import '../../helpers/database_test_helper.dart';

void main() {
  setupDatabaseTests();

  group('ProductDao Tests', () {
    test('Foreign Key Constraints', () async {
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
      await categoryDao.delete(catId);

      final productAfterCatDelete = await productDao.getById(prodId);
      expect(productAfterCatDelete![ProductDao.colCategoryId], isNull);
    });
  });
}