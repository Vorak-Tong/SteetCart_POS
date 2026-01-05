import '../local/dao/category_dao.dart';
import '../../domain/models/product_model.dart';

class CategoryRepository {
  final _categoryDao = CategoryDao();

  Future<List<Category>> getCategories() async {
    final rows = await _categoryDao.getAll();
    return rows.map((row) {
      return Category(
        id: row[CategoryDao.colId] as String,
        name: row[CategoryDao.colName] as String,
      );
    }).toList();
  }

  Future<void> saveCategory(Category category) async {
    await _categoryDao.insert({
      CategoryDao.colId: category.id,
      CategoryDao.colName: category.name,
    });
  }

  Future<void> deleteCategory(String id) async {
    await _categoryDao.delete(id);
  }
}
