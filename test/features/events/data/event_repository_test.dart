import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/core/database/app_database.dart';
import 'package:tasky/core/errors/failures.dart';
import 'package:tasky/features/events/data/datasources/event_local_datasource.dart';
import 'package:tasky/features/events/data/repositories/event_repository_impl.dart';
import 'package:tasky/features/events/domain/entities/event.dart';

void main() {
  late AppDatabase database;
  late EventRepositoryImpl repository;
  final now = DateTime(2026, 11, 14, 9, 30);

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = EventRepositoryImpl(EventLocalDataSourceImpl(database));
  });

  tearDown(() async => database.close());

  Event allDayEvent({String? categoryId}) => Event(
    id: 'event-all-day',
    title: 'Feriado',
    categoryId: categoryId,
    isAllDay: true,
    eventDate: DateTime(2026, 12, 25, 13),
    createdAt: now,
    updatedAt: now,
  );

  Event timedEvent({String id = 'event-timed', String? categoryId}) => Event(
    id: id,
    title: 'Reunión',
    categoryId: categoryId,
    isAllDay: false,
    startAt: DateTime(2026, 12, 25, 10, 15),
    endAt: DateTime(2026, 12, 25, 11, 45),
    createdAt: now,
    updatedAt: now,
  );

  test('round trips all-day and timed event fields', () async {
    await repository.createEvent(allDayEvent());
    await repository.createEvent(timedEvent());

    final allDay = await repository.getEventById('event-all-day');
    expect(allDay, isNotNull);
    expect(allDay!.isAllDay, isTrue);
    expect(allDay.eventDate, DateTime(2026, 12, 25));
    expect(allDay.startAt, isNull);
    expect(allDay.endAt, isNull);
    final storedAllDay = await (database.select(
      database.events,
    )..where((row) => row.id.equals('event-all-day'))).getSingle();
    expect(storedAllDay.eventDate, '2026-12-25');

    final timed = await repository.getEventById('event-timed');
    expect(timed, isNotNull);
    expect(timed!.isAllDay, isFalse);
    expect(timed.eventDate, isNull);
    expect(timed.startAt, DateTime(2026, 12, 25, 10, 15));
    expect(timed.endAt, DateTime(2026, 12, 25, 11, 45));
  });

  test(
    'filters by date and category using the stored date or time range',
    () async {
      final category = (await database.select(database.categories).get()).first;
      await repository.createEvent(allDayEvent(categoryId: category.id));
      await repository.createEvent(timedEvent(categoryId: category.id));
      await repository.createEvent(
        timedEvent(id: 'other-day').copyWith(
          startAt: DateTime(2026, 12, 26, 10),
          endAt: DateTime(2026, 12, 26, 11),
        ),
      );

      final events = await repository.getEvents(
        categoryId: category.id,
        eventDate: DateTime(2026, 12, 25, 20),
      );
      expect(events.map((event) => event.id).toSet(), {
        'event-all-day',
        'event-timed',
      });
    },
  );

  test(
    'deleting a category preserves its event and clears categoryId',
    () async {
      final category = (await database.select(database.categories).get()).first;
      await repository.createEvent(timedEvent(categoryId: category.id));

      await (database.delete(
        database.categories,
      )..where((row) => row.id.equals(category.id))).go();

      final event = await repository.getEventById('event-timed');
      expect(event, isNotNull);
      expect(event!.categoryId, isNull);
    },
  );

  test(
    'updates and deletes events, and maps database errors to Failure',
    () async {
      await repository.createEvent(timedEvent());
      final original = (await repository.getEventById('event-timed'))!;
      await repository.updateEvent(original.copyWith(title: 'Actualizado'));
      expect(
        (await repository.getEventById('event-timed'))!.title,
        'Actualizado',
      );

      await repository.deleteEvent('event-timed');
      expect(await repository.getEventById('event-timed'), isNull);

      await expectLater(
        repository.createEvent(timedEvent(categoryId: 'missing-category')),
        throwsA(isA<DatabaseFailure>()),
      );
    },
  );

  test('repository rejects invalid event intervals', () async {
    final invalid = timedEvent().copyWith(endAt: DateTime(2026, 12, 25, 10));
    await expectLater(
      repository.createEvent(invalid),
      throwsA(isA<ValidationFailure>()),
    );
  });
}
