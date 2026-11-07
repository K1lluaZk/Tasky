import '../../../../core/database/app_database.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryEntry>> getCategories();
  Future<CategoryEntry?> getCategoryById(String id);
  Future<void> insertCategory(CategoriesCompanion category);
  Future<void> updateCategory(CategoriesCompanion category);
  Future<int> deleteCategory(String id);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  const CategoryLocalDataSourceImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<CategoryEntry>> getCategories() {
    return _database.select(_database.categories).get();
  }

  @override
  Future<CategoryEntry?> getCategoryById(String id) {
    return (_database.select(_database.categories)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<void> insertCategory(CategoriesCompanion category) {
    return _database.into(_database.categories).insert(category);
  }

  @override
  Future<void> updateCategory(CategoriesCompanion category) {
    return (_database.update(_database.categories)
          ..where((c) => c.id.equals(category.id.value)))
        .write(category);
  }

  @override
  Future<int> deleteCategory(String id) {
    return (_database.delete(_database.categories)..where((c) => c.id.equals(id))).go();
  }
}
