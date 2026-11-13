import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/task.dart';

extension TaskEntryMapper on TaskEntry {
  Task toDomain() {
    return Task(
      id: id,
      title: title,
      description: description,
      priority: TaskPriorityParsing.fromString(priority),
      status: TaskStatusParsing.fromString(status),
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

extension TaskDomainMapper on Task {
  TasksCompanion toCompanion() {
    return TasksCompanion(
      id: Value(id),
      title: Value(title.trim()),
      description: Value(description?.trim()),
      priority: Value(priority.name),
      status: Value(status.name),
      categoryId: Value(categoryId),
      scheduledDate: Value(_dateToIso(scheduledDate)),
      dueDate: Value(_dateToIso(dueDate)),
      completedAt: Value(completedAt?.millisecondsSinceEpoch),
      createdAt: Value(createdAt.millisecondsSinceEpoch),
      updatedAt: Value(updatedAt.millisecondsSinceEpoch),
    );
  }
}

String? _dateToIso(DateTime? date) {
  if (date == null) return null;
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

DateTime? _parseOptionalDate(String? value) {
  final normalized = value?.trim();
  if (normalized?.isEmpty ?? true) {
    return null;
  }

  final parsed = DateTime.tryParse(normalized!);
  // ignore: prefer_null_aware_operators
  return parsed == null
      ? null
      : DateTime(parsed.year, parsed.month, parsed.day);
}
