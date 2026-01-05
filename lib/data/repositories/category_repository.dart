import '../local/dao/category_dao.dart';
import '../../domain/models/product_model.dart';
import '../../domain/validation/field_limits.dart';

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
    final name = category.name.trim();
    if (name.isEmpty) {
      throw ArgumentError('Category name cannot be empty.');
    }
    if (name.length > FieldLimits.categoryNameMax) {
      throw ArgumentError(
        'Category name must be at most ${FieldLimits.categoryNameMax} characters.',
      );
    }

    await _categoryDao.insert({
      CategoryDao.colId: category.id,
      CategoryDao.colName: name,
    });
  }

  Future<void> deleteCategory(String id) async {
    await _categoryDao.delete(id);
  }
}
