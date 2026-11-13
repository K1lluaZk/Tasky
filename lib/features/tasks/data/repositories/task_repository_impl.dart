import '../../../../core/errors/failures.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../models/task_mapper.dart';

class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl(this._localDataSource);

  final TaskLocalDataSource _localDataSource;

  @override
  Future<void> createTask(Task task) async {
    if (task.title.trim().isEmpty) {
      throw const ValidationFailure('El título de la tarea no puede estar vacío.');
    }

    try {
      await _localDataSource.insertTask(task.toCompanion());
    } catch (e) {
      if (e is Failure) rethrow;
      throw DatabaseFailure('Error al crear la tarea en la base de datos.', e);
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      final deleted = await _localDataSource.deleteTask(id);

      if (deleted == 0) {
        throw const NotFoundFailure('No se encontró la tarea a eliminar.');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw DatabaseFailure('Error al eliminar la tarea en la base de datos.', e);
    }
  }

  @override
  Future<Task?> getTaskById(String id) async {
    try {
      final row = await _localDataSource.getTaskById(id);
      return row?.toDomain();
    } catch (e) {
      if (e is Failure) rethrow;
      throw DatabaseFailure('Error al consultar la tarea por ID.', e);
    }
  }

  @override
  Future<List<Task>> getTasks() async {
    try {
      final rows = await _localDataSource.getTasks();
      return rows.map((row) => row.toDomain()).toList();
    } catch (e) {
      if (e is Failure) rethrow;
      throw DatabaseFailure('Error al consultar la lista de tareas.', e);
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    if (task.title.trim().isEmpty) {
      throw const ValidationFailure('El título de la tarea no puede estar vacío.');
    }

    try {
      final updated = await _localDataSource.updateTask(task.toCompanion());

      if (updated == 0) {
        throw const NotFoundFailure('No se encontró la tarea a actualizar.');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw DatabaseFailure('Error al actualizar la tarea en la base de datos.', e);
    }
  }
}
