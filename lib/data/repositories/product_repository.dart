import 'package:sqflite/sqflite.dart';
import '../local/app_database.dart';
import '../local/dao/category_dao.dart';
import '../local/dao/modifier_dao.dart';
import '../local/dao/product_dao.dart';
import '../../domain/models/product_model.dart';

class ProductRepository {
  final _productDao = ProductDao();
  final _categoryDao = CategoryDao();
  final _modifierDao = ModifierDao();

  // ---------------------------------------------------------------------------
  // Categories
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Products
  // ---------------------------------------------------------------------------

  Future<List<Product>> getProducts() async {
    final productRows = await _productDao.getAll();
    final List<Product> products = [];

    for (final row in productRows) {
      // 1. Fetch Category
      Category? category;
      final catId = row[ProductDao.colCategoryId] as String?;
      if (catId != null) {
        final catRow = await _categoryDao.getById(catId);
        if (catRow != null) {
          category = Category(
            id: catRow[CategoryDao.colId] as String,
            name: catRow[CategoryDao.colName] as String,
          );
        }
      }

      // 2. Fetch Modifiers
      final productId = row[ProductDao.colId] as String;
      final modifierGroups = await _getModifiersForProduct(productId);

      // 3. Assemble Product
      products.add(Product(
        id: productId,
        name: row[ProductDao.colName] as String,
        basePrice: (row[ProductDao.colBasePrice] as num).toDouble(),
        image: row[ProductDao.colImage] as String?,
        category: category,
        modifierGroups: modifierGroups,
      ));
    }

    return products;
  }

  Future<void> createProduct(Product product) async {
    final db = await AppDatabase.instance();
    
    await db.transaction((txn) async {
      // 1. Insert Product
      await _productDao.insert({
        ProductDao.colId: product.id,
        ProductDao.colName: product.name,
        ProductDao.colBasePrice: product.basePrice,
        ProductDao.colImage: product.image,
        ProductDao.colCategoryId: product.category?.id,
      }, txn: txn);

      // 2. Insert Modifiers
      await _saveModifiers(product.id, product.modifierGroups, txn);
    });
  }

  Future<void> updateProduct(Product product) async {
    final db = await AppDatabase.instance();
    
    await db.transaction((txn) async {
      // 1. Update Product
      await _productDao.update({
        ProductDao.colId: product.id,
        ProductDao.colName: product.name,
        ProductDao.colBasePrice: product.basePrice,
        ProductDao.colImage: product.image,
        ProductDao.colCategoryId: product.category?.id,
      }, txn: txn);

      // 2. Replace Modifiers (Delete all old, insert new)
      await _modifierDao.deleteModifiersForProduct(product.id, txn: txn);
      await _saveModifiers(product.id, product.modifierGroups, txn);
    });
  }

  Future<void> deleteProduct(String id) async {
    // Cascading delete in DB handles modifiers, but we can be explicit if needed.
    await _productDao.delete(id);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<List<ModifierGroup>> _getModifiersForProduct(String productId) async {
    final groupRows = await _modifierDao.getGroupsByProductId(productId);
    final List<ModifierGroup> groups = [];

    for (final gRow in groupRows) {
      final groupId = gRow[ModifierDao.colGroupId] as String;
      final optionRows = await _modifierDao.getOptionsByGroupId(groupId);
      
      final options = optionRows.map((oRow) {
        return ModifierOptions(
          id: oRow[ModifierDao.colOptionId] as String,
          name: oRow[ModifierDao.colOptionName] as String,
          price: (oRow[ModifierDao.colOptionPrice] as num?)?.toDouble(),
        );
      }).toList();

      groups.add(ModifierGroup(
        id: groupId,
        name: gRow[ModifierDao.colGroupName] as String,
        modifierOptions: options,
      ));
    }
    return groups;
  }

  Future<void> _saveModifiers(
    String productId, 
    List<ModifierGroup> groups, 
    Transaction txn
  ) async {
    for (final group in groups) {
      // Insert Group
      await _modifierDao.insertGroup({
        ModifierDao.colGroupId: group.id,
        ModifierDao.colGroupName: group.name,
        ModifierDao.colGroupProductId: productId,
      }, txn: txn);

      // Insert Options
      for (final option in group.modifierOptions) {
        await _modifierDao.insertOption({
          ModifierDao.colOptionId: option.id,
          ModifierDao.colOptionName: option.name,
          ModifierDao.colOptionPrice: option.price,
          ModifierDao.colOptionGroupId: group.id,
        }, txn: txn);
      }
    }
  }
}