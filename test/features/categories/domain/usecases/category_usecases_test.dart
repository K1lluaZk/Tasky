import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/core/errors/failures.dart';
import 'package:tasky/features/categories/domain/entities/category.dart';
import 'package:tasky/features/categories/domain/repositories/category_repository.dart';
import 'package:tasky/features/categories/domain/usecases/create_category.dart';
import 'package:tasky/features/categories/domain/usecases/delete_category.dart';
import 'package:tasky/features/categories/domain/usecases/get_categories.dart';
import 'package:tasky/features/categories/domain/usecases/get_category_by_id.dart';
import 'package:tasky/features/categories/domain/usecases/update_category.dart';

class MockCategoryRepository implements CategoryRepository {
  final List<Category> _storage = [];

  @override
  Future<void> createCategory(Category category) async {
    _storage.add(category);
  }

  @override
  Future<void> deleteCategory(String id) async {
    _storage.removeWhere((c) => c.id == id);
  }

  @override
  Future<List<Category>> getCategories() async {
    return List.unmodifiable(_storage);
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    try {
      return _storage.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateCategory(Category category) async {
    final index = _storage.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _storage[index] = category;
    }
  }
}

void main() {
  late MockCategoryRepository repository;
  late GetCategoriesUseCase getCategories;
  late GetCategoryByIdUseCase getCategoryById;
  late CreateCategoryUseCase createCategory;
  late UpdateCategoryUseCase updateCategory;
  late DeleteCategoryUseCase deleteCategory;
  final now = DateTime.now();

  setUp(() {
    repository = MockCategoryRepository();
    getCategories = GetCategoriesUseCase(repository);
    getCategoryById = GetCategoryByIdUseCase(repository);
    createCategory = CreateCategoryUseCase(repository);
    updateCategory = UpdateCategoryUseCase(repository);
    deleteCategory = DeleteCategoryUseCase(repository);
  });

  group('Category UseCases Tests', () {
    test('CreateCategoryUseCase rejects empty name or invalid color', () async {
      final invalidName = Category(
        id: '1',
        name: '   ',
        color: '#2196F3',
        createdAt: now,
        updatedAt: now,
      );

      expect(
        () => createCategory(invalidName),
        throwsA(isA<ValidationFailure>()),
      );

      final invalidColor = Category(
        id: '2',
        name: 'Válido',
        color: 'azul',
        createdAt: now,
        updatedAt: now,
      );

      expect(
        () => createCategory(invalidColor),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test(
      'CreateCategoryUseCase adds category and GetCategoriesUseCase retrieves it',
      () async {
        final category = Category(
          id: '10',
          name: 'Diseño',
          color: '#E91E63',
          createdAt: now,
          updatedAt: now,
        );

        await createCategory(category);

        final list = await getCategories();
        expect(list.length, 1);
        expect(list.first.name, 'Diseño');

        final byId = await getCategoryById('10');
        expect(byId, isNotNull);
        expect(byId!.name, 'Diseño');
      },
    );

    test(
      'UpdateCategoryUseCase rejects invalid hex or updates accurately',
      () async {
        final category = Category(
          id: '11',
          name: 'Finanzas',
          color: '#4CAF50',
          createdAt: now,
          updatedAt: now,
        );
        await createCategory(category);

        expect(
          () => updateCategory(category.copyWith(color: 'azul')),
          throwsA(isA<ValidationFailure>()),
        );

        final updated = category.copyWith(name: 'Finanzas Personales');
        await updateCategory(updated);

        final result = await getCategoryById('11');
        expect(result!.name, 'Finanzas Personales');
      },
    );

    test(
      'DeleteCategoryUseCase throws ConflictFailure when attempting to delete a default category',
      () async {
        final defaultCategory = Category(
          id: 'default-1',
          name: 'Estudios',
          color: '#2196F3',
          isDefault: true,
          createdAt: now,
          updatedAt: now,
        );
        await createCategory(defaultCategory);

        expect(
          () => deleteCategory('default-1'),
          throwsA(isA<ConflictFailure>()),
        );
      },
    );

    test(
      'DeleteCategoryUseCase throws NotFoundFailure when category does not exist',
      () async {
        expect(
          () => deleteCategory('non-existent'),
          throwsA(isA<NotFoundFailure>()),
        );
      },
    );

    test(
      'DeleteCategoryUseCase removes non-default category successfully',
      () async {
        final customCategory = Category(
          id: 'custom-1',
          name: 'Música',
          color: '#9C27B0',
          isDefault: false,
          createdAt: now,
          updatedAt: now,
        );
        await createCategory(customCategory);

        await deleteCategory('custom-1');
        final result = await getCategoryById('custom-1');
        expect(result, isNull);
      },
    );
  });
}
