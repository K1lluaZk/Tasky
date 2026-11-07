import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/update_task.dart';

class TaskController extends StateNotifier<AsyncValue<List<Task>>> {
  TaskController({
    required GetTasksUseCase getTasksUseCase,
    required CreateTaskUseCase createTaskUseCase,
    required UpdateTaskUseCase updateTaskUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
  })  : _getTasksUseCase = getTasksUseCase,
        _createTaskUseCase = createTaskUseCase,
        _updateTaskUseCase = updateTaskUseCase,
        _deleteTaskUseCase = deleteTaskUseCase,
        super(const AsyncLoading()) {
    loadTasks();
  }

  final GetTasksUseCase _getTasksUseCase;
  final CreateTaskUseCase _createTaskUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;

  Future<void> loadTasks() async {
    state = const AsyncLoading();

    try {
      final tasks = await _getTasksUseCase();
      state = AsyncData(tasks);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> addTask(Task task) async {
    try {
      await _createTaskUseCase(task);
      await loadTasks();
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> editTask(Task task) async {
    try {
      await _updateTaskUseCase(task);
      await loadTasks();
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> removeTask(String id) async {
    try {
      await _deleteTaskUseCase(id);
      await loadTasks();
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> toggleTaskStatus(Task task) async {
    final nextStatus = task.status == TaskStatus.completed
        ? TaskStatus.pending
        : TaskStatus.completed;

    final updated = task.copyWith(
      status: nextStatus,
      completedAt: nextStatus == TaskStatus.completed ? DateTime.now() : null,
      clearCompletedAt: nextStatus == TaskStatus.pending,
      updatedAt: DateTime.now(),
    );

    await editTask(updated);
  }
}
