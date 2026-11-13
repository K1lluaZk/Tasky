import '../../../../core/errors/failures.dart';
import '../repositories/category_repository.dart';

class DeleteCategoryUseCase {
  const DeleteCategoryUseCase(this._repository);

  final CategoryRepository _repository;

  Future<void> call(String id) async {
    final category = await _repository.getCategoryById(id);
    if (category == null) {
      throw const NotFoundFailure('No se encontró la categoría a eliminar.');
    }
    if (category.isDefault) {
      throw const ConflictFailure('No se pueden eliminar las categorías predeterminadas del sistema.');
    }

    return _repository.deleteCategory(id);
  }
}
