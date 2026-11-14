import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/core/errors/failures.dart';
import 'package:tasky/features/events/domain/entities/event.dart';
import 'package:tasky/features/events/domain/repositories/event_repository.dart';
import 'package:tasky/features/events/domain/usecases/create_event.dart';
import 'package:tasky/features/events/domain/usecases/update_event.dart';

class _FakeEventRepository implements EventRepository {
  @override
  Future<void> createEvent(Event event) async {}
  @override
  Future<void> deleteEvent(String id) async {}
  @override
  Future<Event?> getEventById(String id) async => null;
  @override
  Future<List<Event>> getEvents({String? categoryId, DateTime? eventDate}) async => [];
  @override
  Future<void> updateEvent(Event event) async {}
}

void main() {
  final now = DateTime(2026, 11, 14, 10);
  final repository = _FakeEventRepository();

  Event timedEvent({DateTime? startAt, DateTime? endAt}) => Event(
        id: 'event-1',
        title: 'Reunión',
        isAllDay: false,
        startAt: startAt ?? now,
        endAt: endAt ?? now.add(const Duration(hours: 1)),
        createdAt: now,
        updatedAt: now,
      );

  test('accepts valid timed interval and rejects endAt equal to startAt', () async {
    final valid = timedEvent();
    expect(valid.isValidTimeInterval, isTrue);
    await CreateEventUseCase(repository)(valid);

    final invalid = timedEvent(endAt: now);
    expect(invalid.isValidTimeInterval, isFalse);
    await expectLater(
      CreateEventUseCase(repository)(invalid),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('rejects endAt before startAt and invalid all-day field combinations', () async {
    final reversed = timedEvent(endAt: now.subtract(const Duration(minutes: 1)));
    await expectLater(
      UpdateEventUseCase(repository)(reversed),
      throwsA(isA<ValidationFailure>()),
    );

    final invalidAllDay = Event(
      id: 'all-day',
      title: 'Día festivo',
      isAllDay: true,
      startAt: now,
      createdAt: now,
      updatedAt: now,
    );
    expect(invalidAllDay.isValidTimeInterval, isFalse);
  });

  test('requires a non-empty title and keeps event fields independent', () async {
    final emptyTitle = timedEvent().copyWith(title: '   ');
    await expectLater(
      CreateEventUseCase(repository)(emptyTitle),
      throwsA(isA<ValidationFailure>()),
    );

    final allDay = Event(
      id: 'day',
      title: 'Feriado',
      isAllDay: true,
      eventDate: DateTime(2026, 12, 25),
      createdAt: now,
      updatedAt: now,
    );
    expect(allDay.isValid, isTrue);
    expect(allDay.copyWith(isAllDay: false, clearEventDate: true).eventDate, isNull);
  });
}
