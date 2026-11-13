import 'package:tasky/core/errors/failures.dart';
import 'package:tasky/features/tasks/domain/entities/task.dart';
import 'package:tasky/features/tasks/domain/repositories/task_repository.dart';

class MockTaskRepository implements TaskRepository {
  MockTaskRepository({this.throwOnMissingUpdate = false});

  final bool throwOnMissingUpdate;
  final List<Task> _tasks = [];

  @override
  Future<List<Task>> getTasks({
    TaskStatus? status,
    String? categoryId,
    DateTime? scheduledDate,
    DateTime? dueDate,
  }) async => List.unmodifiable(
    _tasks.where(
      (task) =>
          (status == null || task.status == status) &&
          (categoryId == null || task.categoryId == categoryId) &&
          (scheduledDate == null || task.scheduledDate == scheduledDate) &&
          (dueDate == null || task.dueDate == dueDate),
    ),
  );

  @override
  Future<Task?> getTaskById(String id) async {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<void> createTask(Task task) async {
    _tasks.add(task);
  }

  @override
  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((existing) => existing.id == task.id);
    if (index == -1) {
      if (throwOnMissingUpdate) {
        throw const NotFoundFailure('Tarea no encontrada.');
      }
      return;
    }
    _tasks[index] = task;
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
  }
}
