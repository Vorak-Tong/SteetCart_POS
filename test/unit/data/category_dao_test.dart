import 'package:flutter_test/flutter_test.dart';
import 'package:street_cart_pos/data/local/dao/category_dao.dart';
import '../../helpers/database_test_helper.dart';

void main() {
  setupDatabaseTests();

  group('CategoryDao Tests', () {
    test('CRUD operations', () async {
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
  });
}
