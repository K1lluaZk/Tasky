import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategoriesUseCase {
  const GetCategoriesUseCase(this._repository);

  final CategoryRepository _repository;

  Future<List<Category>> call() {
    return _repository.getCategories();
  }
}
