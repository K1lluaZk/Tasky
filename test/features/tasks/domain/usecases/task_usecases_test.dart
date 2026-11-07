import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/core/errors/failures.dart';
import 'package:tasky/features/tasks/domain/entities/task.dart';
import 'package:tasky/features/tasks/domain/repositories/task_repository.dart';
import 'package:tasky/features/tasks/domain/usecases/create_task.dart';
import 'package:tasky/features/tasks/domain/usecases/delete_task.dart';
import 'package:tasky/features/tasks/domain/usecases/get_task_by_id.dart';
import 'package:tasky/features/tasks/domain/usecases/get_tasks.dart';
import 'package:tasky/features/tasks/domain/usecases/update_task.dart';

/// Mock repository en memoria para tests de use cases.
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
    if (index == -1) throw const NotFoundFailure('Tarea no encontrada.');
    _tasks[index] = task;
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
  }
}

void main() {
  late MockTaskRepository repository;
  late GetTasksUseCase getTasksUseCase;
  late GetTaskByIdUseCase getTaskByIdUseCase;
  late CreateTaskUseCase createTaskUseCase;
  late UpdateTaskUseCase updateTaskUseCase;
  late DeleteTaskUseCase deleteTaskUseCase;

  final now = DateTime.now();

  setUp(() {
    repository = MockTaskRepository();
    getTasksUseCase = GetTasksUseCase(repository);
    getTaskByIdUseCase = GetTaskByIdUseCase(repository);
    createTaskUseCase = CreateTaskUseCase(repository);
    updateTaskUseCase = UpdateTaskUseCase(repository);
    deleteTaskUseCase = DeleteTaskUseCase(repository);
  });

  group('Task UseCases Tests', () {
    group('CreateTaskUseCase', () {
      test('rejects empty title', () {
        final task = Task(
          id: '1',
          title: '',
          createdAt: now,
          updatedAt: now,
        );

        expect(
          () => createTaskUseCase(task),
          throwsA(isA<ValidationFailure>()),
        );
      });

      test('rejects title with only spaces', () {
        final task = Task(
          id: '2',
          title: '   ',
          createdAt: now,
          updatedAt: now,
        );

        expect(
          () => createTaskUseCase(task),
          throwsA(isA<ValidationFailure>()),
        );
      });

      test('creates task with valid title and retrieves it', () async {
        final task = Task(
          id: '3',
          title: 'Estudiar Flutter',
          description: 'Repasar widgets',
          priority: TaskPriority.high,
          createdAt: now,
          updatedAt: now,
        );

        await createTaskUseCase(task);
        final tasks = await getTasksUseCase();

        expect(tasks, hasLength(1));
        expect(tasks.first.title, 'Estudiar Flutter');
        expect(tasks.first.priority, TaskPriority.high);
      });
    });

    group('GetTaskByIdUseCase', () {
      test('returns task when it exists', () async {
        final task = Task(
          id: 'abc',
          title: 'Tarea existente',
          createdAt: now,
          updatedAt: now,
        );
        await createTaskUseCase(task);

        final found = await getTaskByIdUseCase('abc');
        expect(found, isNotNull);
        expect(found!.title, 'Tarea existente');
      });

      test('returns null when task does not exist', () async {
        final found = await getTaskByIdUseCase('no-existe');
        expect(found, isNull);
      });
    });

    group('UpdateTaskUseCase', () {
      test('rejects empty title on update', () async {
        final task = Task(
          id: '4',
          title: 'Válida',
          createdAt: now,
          updatedAt: now,
        );
        await createTaskUseCase(task);

        final invalid = task.copyWith(title: '');

        expect(
          () => updateTaskUseCase(invalid),
          throwsA(isA<ValidationFailure>()),
        );
      });

      test('updates task title and priority successfully', () async {
        final task = Task(
          id: '5',
          title: 'Original',
          priority: TaskPriority.low,
          createdAt: now,
          updatedAt: now,
        );
        await createTaskUseCase(task);

        final updated = task.copyWith(
          title: 'Actualizada',
          priority: TaskPriority.high,
          updatedAt: DateTime.now(),
        );
        await updateTaskUseCase(updated);

        final found = await getTaskByIdUseCase('5');
        expect(found!.title, 'Actualizada');
        expect(found.priority, TaskPriority.high);
      });
    });

    group('DeleteTaskUseCase', () {
      test('throws NotFoundFailure when task does not exist', () {
        expect(
          () => deleteTaskUseCase('inexistente'),
          throwsA(isA<NotFoundFailure>()),
        );
      });

      test('deletes existing task successfully', () async {
        final task = Task(
          id: '6',
          title: 'Para eliminar',
          createdAt: now,
          updatedAt: now,
        );
        await createTaskUseCase(task);

        await deleteTaskUseCase('6');
        final tasks = await getTasksUseCase();
        expect(tasks, isEmpty);
      });
    });

    group('GetTasksUseCase', () {
      test('returns empty list initially', () async {
        final tasks = await getTasksUseCase();
        expect(tasks, isEmpty);
      });

      test('returns all created tasks', () async {
        for (var i = 0; i < 3; i++) {
          await createTaskUseCase(Task(
            id: 'task-$i',
            title: 'Tarea $i',
            createdAt: now,
            updatedAt: now,
          ));
        }

        final tasks = await getTasksUseCase();
        expect(tasks, hasLength(3));
      });
    });
  });
}
