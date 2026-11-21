import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/event.dart';
import '../../domain/usecases/create_event.dart';
import '../../domain/usecases/delete_event.dart';
import '../../domain/usecases/get_events.dart';
import '../../domain/usecases/update_event.dart';

class EventListNotifier extends StateNotifier<AsyncValue<List<Event>>> {
  EventListNotifier({
    required GetEventsUseCase getEventsUseCase,
    required CreateEventUseCase createEventUseCase,
    required UpdateEventUseCase updateEventUseCase,
    required DeleteEventUseCase deleteEventUseCase,
  }) : _getEventsUseCase = getEventsUseCase,
       _createEventUseCase = createEventUseCase,
       _updateEventUseCase = updateEventUseCase,
       _deleteEventUseCase = deleteEventUseCase,
       super(const AsyncLoading()) {
    loadEvents();
  }

  final GetEventsUseCase _getEventsUseCase;
  final CreateEventUseCase _createEventUseCase;
  final UpdateEventUseCase _updateEventUseCase;
  final DeleteEventUseCase _deleteEventUseCase;

  String? _categoryId;
  DateTime? _eventDate;

  Future<void> loadEvents({String? categoryId, DateTime? eventDate}) async {
    _categoryId = categoryId;
    _eventDate = eventDate;
    state = const AsyncLoading();
    try {
      final events = await _getEventsUseCase(
        categoryId: categoryId,
        eventDate: eventDate,
      );
      state = AsyncData(List.unmodifiable(events));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> createEvent(Event event) async {
    await _performMutation(() => _createEventUseCase(event));
  }

  Future<void> updateEvent(Event event) async {
    await _performMutation(() => _updateEventUseCase(event));
  }

  Future<void> deleteEvent(String id) async {
    await _performMutation(() => _deleteEventUseCase(id));
  }

  Future<void> _performMutation(Future<void> Function() action) async {
    try {
      await action();
      await loadEvents(categoryId: _categoryId, eventDate: _eventDate);
      if (state.hasError) throw state.error!;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
