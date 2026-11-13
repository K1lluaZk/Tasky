import '../entities/task.dart';
import '../repositories/task_repository.dart';

class ToggleTaskStatusUseCase {
  const ToggleTaskStatusUseCase(this._repository);

  final TaskRepository _repository;

  Future<Task> call(Task task, {DateTime? changedAt}) async {
    final nextStatus = task.status == TaskStatus.completed
        ? TaskStatus.pending
        : TaskStatus.completed;
    final timestamp = changedAt ?? DateTime.now();
    final updated = task.copyWith(
      status: nextStatus,
      updatedAt: timestamp,
      completedAt: nextStatus == TaskStatus.completed ? timestamp : null,
      clearCompletedAt: nextStatus != TaskStatus.completed,
    );
    await _repository.updateTask(updated);
    return updated;
  }
}
