import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database_provider.dart';
import '../../features/categories/data/datasources/category_local_datasource.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/entities/category.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/categories/domain/usecases/create_category.dart';
import '../../features/categories/domain/usecases/delete_category.dart';
import '../../features/categories/domain/usecases/get_categories.dart';
import '../../features/categories/domain/usecases/get_category_by_id.dart';
import '../../features/categories/domain/usecases/update_category.dart';
import '../../features/categories/presentation/controllers/category_controller.dart';
import '../../features/tasks/data/datasources/task_local_datasource.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/entities/task.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/domain/usecases/create_task.dart';
import '../../features/tasks/domain/usecases/delete_task.dart';
import '../../features/tasks/domain/usecases/get_task_by_id.dart';
import '../../features/tasks/domain/usecases/get_tasks.dart';
import '../../features/tasks/domain/usecases/update_task.dart';
import '../../features/tasks/presentation/controllers/task_controller.dart';

// ==========================================
// Categorías (Feature: Categories)
// ==========================================

final categoryLocalDataSourceProvider = Provider<CategoryLocalDataSource>((ref) {
  return CategoryLocalDataSourceImpl(ref.watch(appDatabaseProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(categoryLocalDataSourceProvider));
});

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  return GetCategoriesUseCase(ref.watch(categoryRepositoryProvider));
});

final getCategoryByIdUseCaseProvider = Provider<GetCategoryByIdUseCase>((ref) {
  return GetCategoryByIdUseCase(ref.watch(categoryRepositoryProvider));
});

final createCategoryUseCaseProvider = Provider<CreateCategoryUseCase>((ref) {
  return CreateCategoryUseCase(ref.watch(categoryRepositoryProvider));
});

final updateCategoryUseCaseProvider = Provider<UpdateCategoryUseCase>((ref) {
  return UpdateCategoryUseCase(ref.watch(categoryRepositoryProvider));
});

final deleteCategoryUseCaseProvider = Provider<DeleteCategoryUseCase>((ref) {
  return DeleteCategoryUseCase(ref.watch(categoryRepositoryProvider));
});

final categoryControllerProvider =
    StateNotifierProvider<CategoryController, AsyncValue<List<Category>>>((ref) {
  return CategoryController(
    getCategoriesUseCase: ref.watch(getCategoriesUseCaseProvider),
    createCategoryUseCase: ref.watch(createCategoryUseCaseProvider),
    updateCategoryUseCase: ref.watch(updateCategoryUseCaseProvider),
    deleteCategoryUseCase: ref.watch(deleteCategoryUseCaseProvider),
  );
});

// ==========================================
// Tareas (Feature: Tasks)
// ==========================================

final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>((ref) {
  return TaskLocalDataSourceImpl(ref.watch(appDatabaseProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(ref.watch(taskLocalDataSourceProvider));
});

final getTasksUseCaseProvider = Provider<GetTasksUseCase>((ref) {
  return GetTasksUseCase(ref.watch(taskRepositoryProvider));
});

final getTaskByIdUseCaseProvider = Provider<GetTaskByIdUseCase>((ref) {
  return GetTaskByIdUseCase(ref.watch(taskRepositoryProvider));
});

final createTaskUseCaseProvider = Provider<CreateTaskUseCase>((ref) {
  return CreateTaskUseCase(ref.watch(taskRepositoryProvider));
});

final updateTaskUseCaseProvider = Provider<UpdateTaskUseCase>((ref) {
  return UpdateTaskUseCase(ref.watch(taskRepositoryProvider));
});

final deleteTaskUseCaseProvider = Provider<DeleteTaskUseCase>((ref) {
  return DeleteTaskUseCase(ref.watch(taskRepositoryProvider));
});

final taskControllerProvider =
    StateNotifierProvider<TaskController, AsyncValue<List<Task>>>((ref) {
  return TaskController(
    getTasksUseCase: ref.watch(getTasksUseCaseProvider),
    createTaskUseCase: ref.watch(createTaskUseCaseProvider),
    updateTaskUseCase: ref.watch(updateTaskUseCaseProvider),
    deleteTaskUseCase: ref.watch(deleteTaskUseCaseProvider),
  );
});
