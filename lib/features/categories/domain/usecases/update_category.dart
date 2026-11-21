import '../entities/category.dart';
import '../repositories/category_repository.dart';
import 'category_validation.dart';

class UpdateCategoryUseCase {
  const UpdateCategoryUseCase(this._repository);

  final CategoryRepository _repository;

  Future<void> call(Category category) {
    validateCategory(category);
    return _repository.updateCategory(category);
  }
}
