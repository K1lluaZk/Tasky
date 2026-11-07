import 'package:intl/intl.dart';

enum TaskPriority { low, medium, high }

enum TaskStatus { pending, completed, cancelled }

class Task {
  const Task({
    required this.id,
    required this.title,
    this.description,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.categoryId,
    this.scheduledDate,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  final String id;
  final String title;
  final String? description;
  final TaskPriority priority;
  final TaskStatus status;
  final String? categoryId;
  final DateTime? scheduledDate;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  bool get isOverdue {
    if (dueDate == null ||
        status == TaskStatus.completed ||
        status == TaskStatus.cancelled) {
      return false;
    }

    final today = DateTime.now();
    final dueDateOnly = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    final todayOnly = DateTime(today.year, today.month, today.day);

    return dueDateOnly.isBefore(todayOnly);
  }

  String get priorityLabel => priority.name;
  String get statusLabel => status.name;

  String get scheduledDateLabel => scheduledDate == null
      ? 'Sin fecha planificada'
      : DateFormat('dd/MM/yyyy').format(scheduledDate!);

  String get dueDateLabel => dueDate == null
      ? 'Sin fecha límite'
      : DateFormat('dd/MM/yyyy').format(dueDate!);

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    String? categoryId,
    DateTime? scheduledDate,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.priority == priority &&
        other.status == status &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode =>
      Object.hash(id, title, description, priority, status, categoryId);
}
