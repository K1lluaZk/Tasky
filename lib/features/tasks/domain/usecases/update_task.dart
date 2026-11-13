import '../../../../core/errors/failures.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class UpdateTaskUseCase {
  const UpdateTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<void> call(Task task) {
    if (task.title.trim().isEmpty) {
      throw const ValidationFailure(
        'El título de la tarea no puede estar vacío.',
      );
    }

    return _repository.updateTask(task);
  }
}
