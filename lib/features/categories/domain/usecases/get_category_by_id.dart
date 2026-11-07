import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategoryByIdUseCase {
  const GetCategoryByIdUseCase(this._repository);

  final CategoryRepository _repository;

  Future<Category?> call(String id) {
    return _repository.getCategoryById(id);
  }
}
