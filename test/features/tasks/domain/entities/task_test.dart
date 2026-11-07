import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/features/tasks/domain/entities/task.dart';

void main() {
  group('Task Entity Tests', () {
    final now = DateTime.now();

    test('isOverdue should be true when dueDate is yesterday and status is pending', () {
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final task = Task(
        id: '1',
        title: 'Tarea atrasada',
        status: TaskStatus.pending,
        dueDate: yesterday,
        createdAt: now,
        updatedAt: now,
      );

      expect(task.isOverdue, isTrue);
    });

    test('isOverdue should be false when dueDate is today', () {
      final today = DateTime(now.year, now.month, now.day);
      final task = Task(
        id: '2',
        title: 'Tarea de hoy',
        status: TaskStatus.pending,
        dueDate: today,
        createdAt: now,
        updatedAt: now,
      );

      expect(task.isOverdue, isFalse);
    });

    test('isOverdue should be false when dueDate is in the future', () {
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final task = Task(
        id: '3',
        title: 'Tarea futura',
        status: TaskStatus.pending,
        dueDate: tomorrow,
        createdAt: now,
        updatedAt: now,
      );

      expect(task.isOverdue, isFalse);
    });

    test('isOverdue should be false when task is completed, even if dueDate is past', () {
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final task = Task(
        id: '4',
        title: 'Tarea completada a tiempo o atrasada',
        status: TaskStatus.completed,
        dueDate: yesterday,
        completedAt: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(task.isOverdue, isFalse);
    });

    test('isOverdue should be false when task is cancelled, even if dueDate is past', () {
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final task = Task(
        id: '5',
        title: 'Tarea cancelada',
        status: TaskStatus.cancelled,
        dueDate: yesterday,
        createdAt: now,
        updatedAt: now,
      );

      expect(task.isOverdue, isFalse);
    });

    test('isOverdue should be false when task has no dueDate', () {
      final task = Task(
        id: '6',
        title: 'Tarea sin fecha límite',
        status: TaskStatus.pending,
        createdAt: now,
        updatedAt: now,
      );

      expect(task.isOverdue, isFalse);
    });

    test('Labels and copyWith should work correctly', () {
      final task = Task(
        id: '7',
        title: 'Original',
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        scheduledDate: DateTime(2026, 11, 20),
        dueDate: DateTime(2026, 11, 25),
        createdAt: now,
        updatedAt: now,
      );

      expect(task.priorityLabel, 'high');
      expect(task.statusLabel, 'pending');
      expect(task.scheduledDateLabel, '20/11/2026');
      expect(task.dueDateLabel, '25/11/2026');

      final updated = task.copyWith(title: 'Modificado', priority: TaskPriority.low);
      expect(updated.title, 'Modificado');
      expect(updated.priority, TaskPriority.low);
      expect(updated.id, task.id);
    });
  });
}
