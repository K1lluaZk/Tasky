import '../../../../core/database/app_database.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskEntry>> getTasks();
  Future<TaskEntry?> getTaskById(String id);
  Future<void> insertTask(TasksCompanion task);
  Future<int> updateTask(TasksCompanion task);
  Future<int> deleteTask(String id);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  const TaskLocalDataSourceImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<TaskEntry>> getTasks() {
    return _database.select(_database.tasks).get();
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
