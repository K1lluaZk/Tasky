import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/core/database/app_database.dart';
import 'package:tasky/core/errors/failures.dart';
import 'package:tasky/features/categories/data/datasources/category_local_datasource.dart';
import 'package:tasky/features/categories/data/repositories/category_repository_impl.dart';
import 'package:tasky/features/categories/domain/entities/category.dart';

void main() {
  late AppDatabase db;
  late CategoryLocalDataSource localDataSource;
  late CategoryRepositoryImpl repository;
  final now = DateTime.now();

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    localDataSource = CategoryLocalDataSourceImpl(db);
    repository = CategoryRepositoryImpl(localDataSource);
  });

  tearDown(() async {
    await db.close();
  });

  group('CategoryRepositoryImpl Tests', () {
    test('getCategories includes seeded default categories initially', () async {
      final categories = await repository.getCategories();
      expect(categories.length, 4);

      final names = categories.map((c) => c.name).toSet();
      expect(names, containsAll({'Estudios', 'Proyectos', 'Personal', 'Otros'}));
    });

    test('createCategory adds category and getCategoryById retrieves it', () async {
      final category = Category(
        id: 'cat-custom-1',
        name: 'Gimnasio',
        color: '#E91E63',
        createdAt: now,
        updatedAt: now,
      );

      await repository.createCategory(category);

      final retrieved = await repository.getCategoryById('cat-custom-1');
      expect(retrieved, isNotNull);
      expect(retrieved!.id, 'cat-custom-1');
      expect(retrieved.name, 'Gimnasio');
      expect(retrieved.color, '#E91E63');
      expect(retrieved.isDefault, isFalse);

      final all = await repository.getCategories();
      expect(all.length, 5);
    });

    test('updateCategory modifies category in database', () async {
      final category = Category(
        id: 'cat-custom-2',
        name: 'Nutrición',
        color: '#8BC34A',
        createdAt: now,
        updatedAt: now,
      );
      await repository.createCategory(category);

      final updated = category.copyWith(name: 'Nutrición y Salud', color: '#4CAF50');
      await repository.updateCategory(updated);

      final result = await repository.getCategoryById('cat-custom-2');
      expect(result!.name, 'Nutrición y Salud');
      expect(result.color, '#4CAF50');
    });

    test('deleteCategory removes category or throws NotFoundFailure', () async {
      final category = Category(
        id: 'cat-custom-3',
        name: 'Hobbies',
        color: '#00BCD4',
        createdAt: now,
        updatedAt: now,
      );
      await repository.createCategory(category);

      await repository.deleteCategory('cat-custom-3');

      final result = await repository.getCategoryById('cat-custom-3');
      expect(result, isNull);

      expect(
        () => repository.deleteCategory('cat-custom-3'),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });
}
