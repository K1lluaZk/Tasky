import '../../../../core/errors/failures.dart';
import '../entities/category.dart';

void validateCategory(Category category) {
  if (category.name.trim().isEmpty) {
    throw const ValidationFailure(
      'El nombre de la categoría no puede estar vacío.',
    );
  }
  if (!Category.isValidHexColor(category.color)) {
    throw const ValidationFailure(
      'El color debe ser un valor hexadecimal válido (ej. #2196F3).',
    );
  }
}
