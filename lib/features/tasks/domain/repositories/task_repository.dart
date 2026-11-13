import '../entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks({
    TaskStatus? status,
    String? categoryId,
    DateTime? scheduledDate,
    DateTime? dueDate,
  });
  Future<Task?> getTaskById(String id);
  Future<void> createTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
}
