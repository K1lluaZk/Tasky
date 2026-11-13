import '../../../../core/errors/failures.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class UpdateCategoryUseCase {
  const UpdateCategoryUseCase(this._repository);

  final CategoryRepository _repository;

  Future<void> call(Category category) {
    if (category.name.trim().isEmpty) {
      throw const ValidationFailure('El nombre de la categoría no puede estar vacío.');
    }
    if (!Category.isValidHexColor(category.color)) {
      throw const ValidationFailure('El color debe ser un valor hexadecimal válido (ej. #2196F3).');
    }

    return _repository.updateCategory(category);
  }
}
