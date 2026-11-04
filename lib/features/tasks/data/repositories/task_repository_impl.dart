import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl();

  @override
  Future<void> createTask(Task task) async {
    // TODO: implement via Drift datasource in next phase.
  }

  @override
  Future<void> deleteTask(String id) async {
    // TODO: implement via Drift datasource in next phase.
  }

  @override
  Future<Task?> getTaskById(String id) async {
    return null;
  }

  @override
  Future<List<Task>> getTasks() async {
    return const <Task>[];
  }

  @override
  Future<void> updateTask(Task task) async {
    // TODO: implement via Drift datasource in next phase.
  }
}
