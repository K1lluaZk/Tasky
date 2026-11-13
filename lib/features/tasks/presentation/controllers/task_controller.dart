import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/toggle_task_status.dart';

enum TaskListFilter { all, pending, completed }

class TaskListNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  TaskListNotifier({
    required GetTasksUseCase getTasksUseCase,
    required CreateTaskUseCase createTaskUseCase,
    required UpdateTaskUseCase updateTaskUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
    ToggleTaskStatusUseCase? toggleTaskStatusUseCase,
  })  : _getTasksUseCase = getTasksUseCase,
        _createTaskUseCase = createTaskUseCase,
        _updateTaskUseCase = updateTaskUseCase,
        _deleteTaskUseCase = deleteTaskUseCase,
        _toggleTaskStatusUseCase = toggleTaskStatusUseCase,
        super(const AsyncLoading()) {
    loadTasks();
  }

  final GetTasksUseCase _getTasksUseCase;
  final CreateTaskUseCase _createTaskUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final ToggleTaskStatusUseCase? _toggleTaskStatusUseCase;
  TaskListFilter _filter = TaskListFilter.all;
  bool _sortByPriority = false;

  TaskListFilter get filter => _filter;
  bool get sortByPriority => _sortByPriority;

  Future<void> loadTasks() async {
    state = const AsyncLoading();

    try {
      final tasks = await _getTasksUseCase();
      final filtered = switch (_filter) {
        TaskListFilter.all => tasks,
        TaskListFilter.pending =>
          tasks.where((task) => task.status == TaskStatus.pending).toList(),
        TaskListFilter.completed =>
          tasks.where((task) => task.status == TaskStatus.completed).toList(),
      };
      state = AsyncData(_ordered(filtered));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> setFilter(TaskListFilter filter) async {
    _filter = filter;
    await loadTasks();
  }

  Future<void> setPrioritySort(bool enabled) async {
    _sortByPriority = enabled;
    await loadTasks();
  }

  List<Task> _ordered(List<Task> tasks) {
    if (!_sortByPriority) return List.unmodifiable(tasks);
    const rank = {
      TaskPriority.high: 0,
      TaskPriority.medium: 1,
      TaskPriority.low: 2,
    };
    return List.unmodifiable(tasks.toList()
      ..sort((a, b) => rank[a.priority]!.compareTo(rank[b.priority]!)));
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
    try {
      if (_toggleTaskStatusUseCase != null) {
        await _toggleTaskStatusUseCase(task);
        await loadTasks();
      } else {
        final nextStatus = task.status == TaskStatus.completed
            ? TaskStatus.pending
            : TaskStatus.completed;
        final timestamp = DateTime.now();
        await editTask(task.copyWith(
          status: nextStatus,
          updatedAt: timestamp,
          completedAt:
              nextStatus == TaskStatus.completed ? timestamp : null,
          clearCompletedAt: nextStatus != TaskStatus.completed,
        ));
      }
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

/// Backwards-compatible controller name used by the existing presentation.
typedef TaskController = TaskListNotifier;
