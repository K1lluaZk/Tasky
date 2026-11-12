import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetTasksUseCase {
  const GetTasksUseCase(this._repository);

  final TaskRepository _repository;

  Future<List<Task>> call({
    TaskStatus? status,
    String? categoryId,
    DateTime? scheduledDate,
    DateTime? dueDate,
  }) {
    return _repository.getTasks(
      status: status,
      categoryId: categoryId,
      scheduledDate: scheduledDate,
      dueDate: dueDate,
    );
  }
}
