import '../local/app_database.dart';
import '../local/dao/category_dao.dart';
import '../local/dao/modifier_dao.dart';
import '../local/dao/product_dao.dart';
import '../local/dao/product_modifier_group_dao.dart';
import '../../domain/models/product_model.dart';

class ProductRepository {
  final _productDao = ProductDao();
  final _categoryDao = CategoryDao();
  final _modifierDao = ModifierDao();
  final _productModifierGroupDao = ProductModifierGroupDao();

  // Products
  Future<List<Product>> getProducts({bool includeInactive = false}) async {
    final productRows = await _productDao.getAll(
      includeInactive: includeInactive,
    );
    final List<Product> products = [];

    for (final row in productRows) {
      // Fetch Category
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

      // Fetch Modifiers
      final productId = row[ProductDao.colId] as String;
      final modifierGroups = await _getModifiersForProduct(productId);

      // Assemble Product
      products.add(
        Product(
          id: productId,
          name: row[ProductDao.colName] as String,
          description: row[ProductDao.colDescription] as String?,
          basePrice: (row[ProductDao.colBasePrice] as num).toDouble(),
          imagePath: row[ProductDao.colImage] as String?,
          isActive: (row[ProductDao.colIsActive] as int? ?? 1) == 1,
          category: category,
          modifierGroups: modifierGroups,
        ),
      );
    }

    return products;
  }

  Future<void> createProduct(Product product) async {
    final db = await AppDatabase.instance();

    await db.transaction((txn) async {
      // Insert Product
      await _productDao.insert({
        ProductDao.colId: product.id,
        ProductDao.colName: product.name,
        ProductDao.colDescription: product.description,
        ProductDao.colBasePrice: product.basePrice,
        ProductDao.colImage: product.imagePath,
        ProductDao.colIsActive: product.isActive ? 1 : 0,
        ProductDao.colCategoryId: product.category?.id,
      }, txn: txn);

      // Attach Modifiers (optional)
      await _productModifierGroupDao.replaceGroupIdsForProduct(
        product.id,
        product.modifierGroups.map((g) => g.id).toList(growable: false),
        txn: txn,
      );
    });
  }

  Future<void> updateProduct(Product product) async {
    final db = await AppDatabase.instance();

    await db.transaction((txn) async {
      // Update Product
      await _productDao.update({
        ProductDao.colId: product.id,
        ProductDao.colName: product.name,
        ProductDao.colDescription: product.description,
        ProductDao.colBasePrice: product.basePrice,
        ProductDao.colImage: product.imagePath,
        ProductDao.colIsActive: product.isActive ? 1 : 0,
        ProductDao.colCategoryId: product.category?.id,
      }, txn: txn);

      // Replace Modifiers (detach all, attach selected)
      await _productModifierGroupDao.replaceGroupIdsForProduct(
        product.id,
        product.modifierGroups.map((g) => g.id).toList(growable: false),
        txn: txn,
      );
    });
  }

  Future<void> deleteProduct(String id) async {
    await _productDao.delete(id);
  }

  Future<void> archiveProduct(String id) async {
    final db = await AppDatabase.instance();
    await db.update(
      ProductDao.tableName,
      {ProductDao.colIsActive: 0},
      where: '${ProductDao.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<void> unarchiveProduct(String id) async {
    final db = await AppDatabase.instance();
    await db.update(
      ProductDao.tableName,
      {ProductDao.colIsActive: 1},
      where: '${ProductDao.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<List<ModifierGroup>> _getModifiersForProduct(String productId) async {
    final groupIds = await _productModifierGroupDao.getGroupIdsByProductId(
      productId,
    );
    if (groupIds.isEmpty) return const [];

    final groupRows = await _modifierDao.getGroupsByIds(groupIds);
    final List<ModifierGroup> groups = [];

    for (final gRow in groupRows) {
      final groupId = gRow[ModifierDao.colGroupId] as String;
      final optionRows = await _modifierDao.getOptionsByGroupId(groupId);

      final options = optionRows.map((oRow) {
        return ModifierOptions(
          id: oRow[ModifierDao.colOptionId] as String,
          name: oRow[ModifierDao.colOptionName] as String,
          price: (oRow[ModifierDao.colOptionPrice] as num?)?.toDouble(),
          isDefault: (oRow[ModifierDao.colOptionIsDefault] as int? ?? 0) == 1,
        );
      }).toList();

      groups.add(
        ModifierGroup(
          id: groupId,
          name: gRow[ModifierDao.colGroupName] as String,
          selectionType: ModifierSelectionType
              .values[gRow[ModifierDao.colSelectionType] as int? ?? 0],
          priceBehavior: ModifierPriceBehavior
              .values[gRow[ModifierDao.colPriceBehavior] as int? ?? 1],
          minSelection: gRow[ModifierDao.colMinSelection] as int? ?? 0,
          maxSelection: gRow[ModifierDao.colMaxSelection] as int? ?? 1,
          modifierOptions: options,
        ),
      );
    }
    return groups;
  }
}
