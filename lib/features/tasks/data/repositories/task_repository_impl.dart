import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<void> createTask(Task task) async {
    final companion = TasksCompanion(
      id: Value(task.id),
      title: Value(task.title),
      description: Value(task.description),
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
  }

  @override
  Future<void> deleteTask(String id) async {
    final deleted = await (_database.delete(_database.tasks)
          ..where((tbl) => tbl.id.equals(id)))
        .go();

    if (deleted == 0) {
      return;
    }
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final row = await (_database.select(_database.tasks)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();

    return row?.toDomain();
  }

  @override
  Future<List<Task>> getTasks() async {
    final rows = await _database.select(_database.tasks).get();
    return rows.map((row) => row.toDomain()).toList();
  }

  @override
  Future<void> updateTask(Task task) async {
    final companion = TasksCompanion(
      id: Value(task.id),
      title: Value(task.title),
      description: Value(task.description),
      priority: Value(_priorityToString(task.priority)),
      status: Value(_statusToString(task.status)),
      categoryId: Value(task.categoryId),
      scheduledDate: Value(_dateToIso(task.scheduledDate)),
      dueDate: Value(_dateToIso(task.dueDate)),
      completedAt: Value(task.completedAt?.millisecondsSinceEpoch),
      createdAt: Value(task.createdAt.millisecondsSinceEpoch),
      updatedAt: Value(task.updatedAt.millisecondsSinceEpoch),
    );

    await (_database.update(_database.tasks)
          ..where((tbl) => tbl.id.equals(task.id)))
        .write(companion);
  }
}

String _priorityToString(TaskPriority priority) => priority.name;
String _statusToString(TaskStatus status) => status.name;
String? _dateToIso(DateTime? date) => date?.toIso8601String();

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
