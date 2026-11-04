import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/core/database/app_database.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;
  const uuid = Uuid();

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase Tests', () {
    test('Initial migration seeds default categories', () async {
      final seeded = await db.select(db.categories).get();

      expect(seeded.length, 4);
      final names = seeded.map((c) => c.name).toSet();
      expect(names, containsAll({'Estudios', 'Proyectos', 'Personal', 'Otros'}));
      for (final cat in seeded) {
        expect(cat.isDefault, isTrue);
        expect(cat.color, startsWith('#'));
      }
    });

    test('Tasks table CRUD and foreign key SET NULL behavior', () async {
      final seededCategories = await db.select(db.categories).get();
      final category = seededCategories.first;
      final now = DateTime.now().millisecondsSinceEpoch;

      final taskId = uuid.v4();
      await db.into(db.tasks).insert(
            TasksCompanion.insert(
              id: taskId,
              title: 'Prueba de Tarea',
              priority: const Value('high'),
              status: const Value('pending'),
              categoryId: Value(category.id),
              scheduledDate: const Value('2026-11-10'),
              dueDate: const Value('2026-11-15'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final task = await (db.select(db.tasks)..where((t) => t.id.equals(taskId))).getSingle();
      expect(task.title, 'Prueba de Tarea');
      expect(task.priority, 'high');
      expect(task.status, 'pending');
      expect(task.categoryId, category.id);
      expect(task.scheduledDate, '2026-11-10');
      expect(task.dueDate, '2026-11-15');

      // Delete the category and verify categoryId becomes NULL
      await (db.delete(db.categories)..where((c) => c.id.equals(category.id))).go();

      final updatedTask =
          await (db.select(db.tasks)..where((t) => t.id.equals(taskId))).getSingle();
      expect(updatedTask.categoryId, isNull);
    });

    test('Events table allows all-day event and timed event', () async {
      final now = DateTime.now().millisecondsSinceEpoch;

      // 1. All-day event
      final allDayId = uuid.v4();
      await db.into(db.events).insert(
            EventsCompanion.insert(
              id: allDayId,
              title: 'Conferencia Anual',
              eventDate: const Value('2026-12-01'),
              isAllDay: const Value(true),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final allDayEvent =
          await (db.select(db.events)..where((e) => e.id.equals(allDayId))).getSingle();
      expect(allDayEvent.isAllDay, isTrue);
      expect(allDayEvent.eventDate, '2026-12-01');
      expect(allDayEvent.startAt, isNull);
      expect(allDayEvent.endAt, isNull);

      // 2. Timed event
      final timedId = uuid.v4();
      final startAt = now;
      final endAt = now + 3600000; // +1 hour

      await db.into(db.events).insert(
            EventsCompanion.insert(
              id: timedId,
              title: 'Reunión de Equipo',
              startAt: Value(startAt),
              endAt: Value(endAt),
              isAllDay: const Value(false),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final timedEvent =
          await (db.select(db.events)..where((e) => e.id.equals(timedId))).getSingle();
      expect(timedEvent.isAllDay, isFalse);
      expect(timedEvent.eventDate, isNull);
      expect(timedEvent.startAt, startAt);
      expect(timedEvent.endAt, endAt);
    });
  });
}
