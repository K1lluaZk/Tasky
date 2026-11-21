import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/features/tasks/domain/entities/task.dart';
import 'package:tasky/features/tasks/domain/usecases/create_task.dart';
import 'package:tasky/features/tasks/domain/usecases/delete_task.dart';
import 'package:tasky/features/tasks/domain/usecases/get_tasks.dart';
import 'package:tasky/features/tasks/domain/usecases/update_task.dart';
import 'package:tasky/features/tasks/presentation/controllers/task_controller.dart';

import '../../../support/mock_task_repository.dart';

void main() {
  late MockTaskRepository repository;
  late TaskController controller;
  final now = DateTime.now();

  setUp(() {
    repository = MockTaskRepository();
    controller = TaskController(
      getTasksUseCase: GetTasksUseCase(repository),
      createTaskUseCase: CreateTaskUseCase(repository),
      updateTaskUseCase: UpdateTaskUseCase(repository),
      deleteTaskUseCase: DeleteTaskUseCase(repository),
    );
  });

  group('TaskController Tests', () {
    test('loads tasks initially with empty list', () async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(controller.state, isA<AsyncData<List<Task>>>());
      expect(controller.state.value, isEmpty);
    });

    test('addTask persists task and updates state', () async {
      final task = Task(
        id: 't-1',
        title: 'Comprar comida',
        createdAt: now,
        updatedAt: now,
      );

      await controller.addTask(task);

      expect(controller.state.value, hasLength(1));
      expect(controller.state.value!.first.title, 'Comprar comida');
    });

    test('editTask modifies task in state', () async {
      final task = Task(
        id: 't-2',
        title: 'Original',
        createdAt: now,
        updatedAt: now,
      );
      await controller.addTask(task);

      await controller.editTask(task.copyWith(title: 'Editado'));

      expect(controller.state.value!.first.title, 'Editado');
    });

    test('removeTask deletes task from state', () async {
      final task = Task(
        id: 't-3',
        title: 'Eliminar',
        createdAt: now,
        updatedAt: now,
      );
      await controller.addTask(task);
      expect(controller.state.value, hasLength(1));

      await controller.removeTask('t-3');
      expect(controller.state.value, isEmpty);
    });

    test(
      'toggleTaskStatus switches pending to completed and vice versa',
      () async {
        final task = Task(
          id: 't-4',
          title: 'Completar luego',
          status: TaskStatus.pending,
          createdAt: now,
          updatedAt: now,
        );
        await controller.addTask(task);

        await controller.toggleTaskStatus(task);
        expect(controller.state.value!.first.status, TaskStatus.completed);
        expect(controller.state.value!.first.completedAt, isNotNull);

        await controller.toggleTaskStatus(controller.state.value!.first);
        expect(controller.state.value!.first.status, TaskStatus.pending);
        expect(controller.state.value!.first.completedAt, isNull);
      },
    );

    test('setFilter exposes only pending or completed tasks', () async {
      await controller.addTask(
        Task(id: 'pending', title: 'Pendiente', createdAt: now, updatedAt: now),
      );
      await controller.addTask(
        Task(
          id: 'completed',
          title: 'Hecha',
          status: TaskStatus.completed,
          completedAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await controller.setFilter(TaskListFilter.pending);
      expect(controller.state.value!.map((task) => task.id), ['pending']);

      await controller.setFilter(TaskListFilter.completed);
      expect(controller.state.value!.map((task) => task.id), ['completed']);

      await controller.setFilter(TaskListFilter.all);
      expect(controller.state.value, hasLength(2));
    });

    test('setPrioritySort orders high, medium, then low', () async {
      for (final priority in [
        TaskPriority.low,
        TaskPriority.high,
        TaskPriority.medium,
      ]) {
        await controller.addTask(
          Task(
            id: priority.name,
            title: priority.name,
            priority: priority,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      await controller.setPrioritySort(true);
      expect(controller.state.value!.map((task) => task.priority), [
        TaskPriority.high,
        TaskPriority.medium,
        TaskPriority.low,
      ]);
    });
  });
}
