import '../../../../core/errors/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/category_validation.dart';
import '../datasources/category_local_datasource.dart';
import '../models/category_mapper.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._localDataSource);

  final CategoryLocalDataSource _localDataSource;

  @override
  Future<void> createCategory(Category category) async {
    validateCategory(category);

    try {
      // Only database seeding may create system categories.
      final userCategory = category.copyWith(isDefault: false);
      await _localDataSource.insertCategory(userCategory.toCompanion());
    } catch (e) {
      if (e is Failure) rethrow;
      throw DatabaseFailure('Error al guardar la categoría en la base de datos.', e);
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      final category = await _localDataSource.getCategoryById(id);
      if (category == null) {
        throw const NotFoundFailure('No se encontró la categoría a eliminar.');
      }
      if (category.isDefault) {
        throw const ConflictFailure(
          'No se pueden eliminar las categorías predeterminadas del sistema.',
        );
      }

      final rowsAffected = await _localDataSource.deleteCategory(id);
      if (rowsAffected == 0) {
        throw const NotFoundFailure('No se encontró la categoría a eliminar.');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw DatabaseFailure('Error al eliminar la categoría en la base de datos.', e);
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final entries = await _localDataSource.getCategories();
      return entries.map((entry) => entry.toDomain()).toList();
    } catch (e) {
      if (e is Failure) rethrow;
      throw DatabaseFailure('Error al consultar las categorías.', e);
    }
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    try {
      final entry = await _localDataSource.getCategoryById(id);
      return entry?.toDomain();
    } catch (e) {
      if (e is Failure) rethrow;
      throw DatabaseFailure('Error al consultar la categoría por ID.', e);
    }
  }

  @override
  Future<void> updateCategory(Category category) async {
    validateCategory(category);

    try {
      final existing = await _localDataSource.getCategoryById(category.id);
      if (existing == null) {
        throw const NotFoundFailure('No se encontró la categoría a actualizar.');
      }

      // Keep system categories protected even when the repository is called
      // directly with an entity whose isDefault flag was changed by a caller.
      final categoryToSave = category.copyWith(isDefault: existing.isDefault);
      await _localDataSource.updateCategory(categoryToSave.toCompanion());
    } catch (e) {
      if (e is Failure) rethrow;
      throw DatabaseFailure('Error al actualizar la categoría en la base de datos.', e);
    }
  }
}
