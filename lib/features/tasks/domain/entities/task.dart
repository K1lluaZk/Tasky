import 'task_priority.dart';
import 'task_status.dart';

export 'task_priority.dart';
export 'task_status.dart';

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
        status != TaskStatus.pending) {
      return false;
    }

    final today = DateTime.now();
    final dueDateOnly = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    final todayOnly = DateTime(today.year, today.month, today.day);

    return dueDateOnly.isBefore(todayOnly);
  }

  String get priorityLabel => priority.name;
  String get statusLabel => status.name;

  String get scheduledDateLabel => _dateLabel(scheduledDate, 'Sin fecha planificada');

  String get dueDateLabel => dueDate == null
      ? 'Sin fecha límite'
      : _dateLabel(dueDate, 'Sin fecha límite');

  String _dateLabel(DateTime? date, String emptyLabel) {
    if (date == null) return emptyLabel;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

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
    bool clearCompletedAt = false,
    bool clearDescription = false,
    bool clearCategoryId = false,
    bool clearScheduledDate = false,
    bool clearDueDate = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      priority: priority ?? this.priority,
      status: status ?? this.status,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      scheduledDate: clearScheduledDate ? null : (scheduledDate ?? this.scheduledDate),
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  Task withStatus(TaskStatus nextStatus, {DateTime? changedAt}) {
    final timestamp = changedAt ?? DateTime.now();
    return copyWith(
      status: nextStatus,
      updatedAt: timestamp,
      completedAt: nextStatus == TaskStatus.completed ? timestamp : null,
      clearCompletedAt: nextStatus != TaskStatus.completed,
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
        other.categoryId == categoryId &&
        other.scheduledDate == scheduledDate &&
        other.dueDate == dueDate &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.completedAt == completedAt;
  }

  @override
  int get hashCode =>
      Object.hash(id, title, description, priority, status, categoryId,
          scheduledDate, dueDate, createdAt, updatedAt, completedAt);
}
