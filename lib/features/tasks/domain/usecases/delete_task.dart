import '../../../../core/errors/failures.dart';
import '../repositories/task_repository.dart';

class DeleteTaskUseCase {
  const DeleteTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<void> call(String id) async {
    final task = await _repository.getTaskById(id);
    if (task == null) {
      throw const NotFoundFailure(
        'No se encontró la tarea a eliminar.',
      );
    }

    return _repository.deleteTask(id);
  }
}
