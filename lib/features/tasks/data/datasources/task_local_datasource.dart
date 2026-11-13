import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/task.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskEntry>> getTasks({
    TaskStatus? status,
    String? categoryId,
    String? scheduledDate,
    String? dueDate,
  });
  Future<TaskEntry?> getTaskById(String id);
  Future<void> insertTask(TasksCompanion task);
  Future<int> updateTask(TasksCompanion task);
  Future<int> deleteTask(String id);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  const TaskLocalDataSourceImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<TaskEntry>> getTasks({
    TaskStatus? status,
    String? categoryId,
    String? scheduledDate,
    String? dueDate,
  }) {
    final query = _database.select(_database.tasks);
    query.where((task) {
      Expression<bool> condition = const Constant(true);
      if (status != null) condition = condition & task.status.equals(status.name);
      if (categoryId != null) {
        condition = condition & task.categoryId.equals(categoryId);
      }
      if (scheduledDate != null) {
        condition = condition & task.scheduledDate.equals(scheduledDate);
      }
      if (dueDate != null) condition = condition & task.dueDate.equals(dueDate);
      return condition;
    });
    return query.get();
  }

  @override
  Future<TaskEntry?> getTaskById(String id) {
    return (_database.select(_database.tasks)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<void> insertTask(TasksCompanion task) {
    return _database.into(_database.tasks).insert(task);
  }

  @override
  Future<int> updateTask(TasksCompanion task) {
    return (_database.update(_database.tasks)
          ..where((t) => t.id.equals(task.id.value)))
        .write(task);
  }

  @override
  Future<int> deleteTask(String id) {
    return (_database.delete(_database.tasks)..where((t) => t.id.equals(id)))
        .go();
  }
}
