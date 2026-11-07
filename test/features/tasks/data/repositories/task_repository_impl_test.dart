import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/core/database/app_database.dart';
import 'package:tasky/core/errors/failures.dart';
import 'package:tasky/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:tasky/features/tasks/domain/entities/task.dart';

void main() {
  late AppDatabase db;
  late TaskRepositoryImpl repository;
  final now = DateTime.now();

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = TaskRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('TaskRepositoryImpl Tests', () {
    test('createTask and getTaskById / getTasks should work correctly', () async {
      final task = Task(
        id: 'task-1',
        title: 'Comprar víveres',
        description: 'Leche, huevos, pan',
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        scheduledDate: DateTime(2026, 11, 10),
        dueDate: DateTime(2026, 11, 12),
        createdAt: now,
        updatedAt: now,
      );

      await repository.createTask(task);

      final retrieved = await repository.getTaskById('task-1');
      expect(retrieved, isNotNull);
      expect(retrieved!.id, 'task-1');
      expect(retrieved.title, 'Comprar víveres');
      expect(retrieved.description, 'Leche, huevos, pan');
      expect(retrieved.priority, TaskPriority.high);
      expect(retrieved.status, TaskStatus.pending);
      expect(retrieved.scheduledDate, DateTime(2026, 11, 10));
      expect(retrieved.dueDate, DateTime(2026, 11, 12));

      final allTasks = await repository.getTasks();
      expect(allTasks.length, 1);
      expect(allTasks.first.id, 'task-1');
    });

    test('createTask with empty title should throw ValidationFailure', () async {
      final task = Task(
        id: 'task-empty',
        title: '   ',
        createdAt: now,
        updatedAt: now,
      );

      expect(
        () => repository.createTask(task),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('updateTask should update task data in database', () async {
      final task = Task(
        id: 'task-2',
        title: 'Estudiar Drift',
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        createdAt: now,
        updatedAt: now,
      );
      await repository.createTask(task);

      final updatedTask = task.copyWith(
        title: 'Estudiar Drift y Riverpod',
        status: TaskStatus.completed,
        completedAt: now,
      );
      await repository.updateTask(updatedTask);

      final result = await repository.getTaskById('task-2');
      expect(result!.title, 'Estudiar Drift y Riverpod');
      expect(result.status, TaskStatus.completed);
      expect(result.completedAt, isNotNull);
    });

    test('updateTask with non-existent id should throw NotFoundFailure', () async {
      final task = Task(
        id: 'task-non-existent',
        title: 'No existe',
        createdAt: now,
        updatedAt: now,
      );

      expect(
        () => repository.updateTask(task),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('deleteTask should delete task and throw NotFoundFailure on subsequent deletion', () async {
      final task = Task(
        id: 'task-3',
        title: 'Eliminar esta tarea',
        createdAt: now,
        updatedAt: now,
      );
      await repository.createTask(task);

      await repository.deleteTask('task-3');

      final result = await repository.getTaskById('task-3');
      expect(result, isNull);

      expect(
        () => repository.deleteTask('task-3'),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });
}
