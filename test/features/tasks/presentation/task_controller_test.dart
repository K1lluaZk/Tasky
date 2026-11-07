import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/features/tasks/domain/entities/task.dart';
import 'package:tasky/features/tasks/domain/repositories/task_repository.dart';
import 'package:tasky/features/tasks/domain/usecases/create_task.dart';
import 'package:tasky/features/tasks/domain/usecases/delete_task.dart';
import 'package:tasky/features/tasks/domain/usecases/get_tasks.dart';
import 'package:tasky/features/tasks/domain/usecases/update_task.dart';
import 'package:tasky/features/tasks/presentation/controllers/task_controller.dart';

class MockTaskRepository implements TaskRepository {
  final List<Task> _tasks = [];

  @override
  Future<List<Task>> getTasks() async => List.unmodifiable(_tasks);

  @override
  Future<Task?> getTaskById(String id) async {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createTask(Task task) async {
    _tasks.add(task);
  }

  @override
  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
  }
}

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

    test('toggleTaskStatus switches pending to completed and vice versa', () async {
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
    });
  });
}
