import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetTaskByIdUseCase {
  const GetTaskByIdUseCase(this._repository);

  final TaskRepository _repository;

  Future<Task?> call(String id) {
    return _repository.getTaskById(id);
  }
}
