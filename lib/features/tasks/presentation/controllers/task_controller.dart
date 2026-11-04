import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task.dart';
import '../../domain/usecases/get_tasks.dart';

class TaskController extends StateNotifier<AsyncValue<List<Task>>> {
  TaskController(this._getTasksUseCase) : super(const AsyncLoading()) {
    loadTasks();
  }

  final GetTasksUseCase _getTasksUseCase;

  Future<void> loadTasks() async {
    state = const AsyncLoading();

    try {
      final tasks = await _getTasksUseCase();
      state = AsyncData(tasks);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
