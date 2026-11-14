import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/features/events/domain/entities/event.dart';
import 'package:tasky/features/events/domain/repositories/event_repository.dart';
import 'package:tasky/features/events/domain/usecases/create_event.dart';
import 'package:tasky/features/events/domain/usecases/delete_event.dart';
import 'package:tasky/features/events/domain/usecases/get_events.dart';
import 'package:tasky/features/events/domain/usecases/update_event.dart';
import 'package:tasky/features/events/presentation/controllers/event_controller.dart';

class _MemoryEventRepository implements EventRepository {
  final List<Event> events = [];

  @override
  Future<void> createEvent(Event event) async => events.add(event);

  @override
  Future<void> deleteEvent(String id) async =>
      events.removeWhere((event) => event.id == id);

  @override
  Future<Event?> getEventById(String id) async {
    for (final event in events) {
      if (event.id == id) return event;
    }
    return null;
  }

  @override
  Future<List<Event>> getEvents({
    String? categoryId,
    DateTime? eventDate,
  }) async => events.where((event) {
    final sameCategory = categoryId == null || event.categoryId == categoryId;
    final sameDate =
        eventDate == null ||
        (event.isAllDay
            ? event.eventDate!.year == eventDate.year &&
                  event.eventDate!.month == eventDate.month &&
                  event.eventDate!.day == eventDate.day
            : event.startAt!.year == eventDate.year &&
                  event.startAt!.month == eventDate.month &&
                  event.startAt!.day == eventDate.day);
    return sameCategory && sameDate;
  }).toList();

  @override
  Future<void> updateEvent(Event event) async {
    final index = events.indexWhere((item) => item.id == event.id);
    if (index >= 0) events[index] = event;
  }
}

void main() {
  late _MemoryEventRepository repository;
  late EventListNotifier notifier;
  final now = DateTime(2026, 11, 14, 10);

  setUp(() {
    repository = _MemoryEventRepository();
    notifier = EventListNotifier(
      getEventsUseCase: GetEventsUseCase(repository),
      createEventUseCase: CreateEventUseCase(repository),
      updateEventUseCase: UpdateEventUseCase(repository),
      deleteEventUseCase: DeleteEventUseCase(repository),
    );
  });

  tearDown(() => notifier.dispose());

  Event makeEvent({String title = 'Reunión'}) => Event(
    id: 'event-1',
    title: title,
    isAllDay: false,
    startAt: now,
    endAt: now.add(const Duration(hours: 1)),
    createdAt: now,
    updatedAt: now,
  );

  test(
    'loads events as AsyncData and refreshes after create/update/delete',
    () async {
      await Future<void>.delayed(Duration.zero);
      expect(notifier.state, isA<AsyncData<List<Event>>>());
      expect(notifier.state.value, isEmpty);

      await notifier.createEvent(makeEvent());
      expect(notifier.state.value, hasLength(1));

      await notifier.updateEvent(makeEvent(title: 'Actualizado'));
      expect(notifier.state.value!.single.title, 'Actualizado');

      await notifier.deleteEvent('event-1');
      expect(notifier.state.value, isEmpty);
    },
  );
}
