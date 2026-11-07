import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<void> createTask(Task task) async {
    if (task.title.trim().isEmpty) {
      throw const ValidationFailure('El título de la tarea no puede estar vacío.');
    }

    try {
      final companion = TasksCompanion(
        id: Value(task.id),
        title: Value(task.title.trim()),
        description: Value(task.description?.trim()),
        priority: Value(_priorityToString(task.priority)),
        status: Value(_statusToString(task.status)),
        categoryId: Value(task.categoryId),
        scheduledDate: Value(_dateToIso(task.scheduledDate)),
        dueDate: Value(_dateToIso(task.dueDate)),
        completedAt: Value(task.completedAt?.millisecondsSinceEpoch),
        createdAt: Value(task.createdAt.millisecondsSinceEpoch),
        updatedAt: Value(task.updatedAt.millisecondsSinceEpoch),
      );

      await _database.into(_database.tasks).insert(companion);
    } catch (e) {
      if (e is Failure) rethrow;
      throw DatabaseFailure('Error al crear la tarea en la base de datos.', e);
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      final deleted = await (_database.delete(_database.tasks)
            ..where((tbl) => tbl.id.equals(id)))
          .go();

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
      final row = await (_database.select(_database.tasks)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingleOrNull();

      return row?.toDomain();
    } catch (e) {
      if (e is Failure) rethrow;
      throw DatabaseFailure('Error al consultar la tarea por ID.', e);
    }
  }

  @override
  Future<List<Task>> getTasks() async {
    try {
      final rows = await _database.select(_database.tasks).get();
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
      final companion = TasksCompanion(
        id: Value(task.id),
        title: Value(task.title.trim()),
        description: Value(task.description?.trim()),
        priority: Value(_priorityToString(task.priority)),
        status: Value(_statusToString(task.status)),
        categoryId: Value(task.categoryId),
        scheduledDate: Value(_dateToIso(task.scheduledDate)),
        dueDate: Value(_dateToIso(task.dueDate)),
        completedAt: Value(task.completedAt?.millisecondsSinceEpoch),
        createdAt: Value(task.createdAt.millisecondsSinceEpoch),
        updatedAt: Value(task.updatedAt.millisecondsSinceEpoch),
      );

      final updated = await (_database.update(_database.tasks)
            ..where((tbl) => tbl.id.equals(task.id)))
          .write(companion);

      if (updated == 0) {
        throw const NotFoundFailure('No se encontró la tarea a actualizar.');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw DatabaseFailure('Error al actualizar la tarea en la base de datos.', e);
    }
  }
}

String _priorityToString(TaskPriority priority) => priority.name;
String _statusToString(TaskStatus status) => status.name;

String? _dateToIso(DateTime? date) {
  if (date == null) return null;
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

extension TaskEntryMapper on TaskEntry {
  Task toDomain() {
    return Task(
      id: id,
      title: title,
      description: description,
      priority: TaskPriority.values.firstWhere(
        (value) => value.name == priority,
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (value) => value.name == status,
        orElse: () => TaskStatus.pending,
      ),
      categoryId: categoryId,
      scheduledDate: _parseOptionalDate(scheduledDate),
      dueDate: _parseOptionalDate(dueDate),
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
      // ignore: prefer_null_aware_operators
      completedAt: completedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(completedAt!),
    );
  }
}

DateTime? _parseOptionalDate(String? value) {
  final normalized = value?.trim();
  if (normalized?.isEmpty ?? true) {
    return null;
  }

  final parsed = DateTime.tryParse(normalized!);
  // ignore: prefer_null_aware_operators
  return parsed == null ? null : DateTime(parsed.year, parsed.month, parsed.day);
}
