import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/datasources/event_local_datasource.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/usecases/create_event.dart';
import '../../domain/usecases/delete_event.dart';
import '../../domain/usecases/get_events.dart';
import '../../domain/usecases/update_event.dart';

final eventLocalDataSourceProvider = Provider<EventLocalDataSource>((ref) {
  return EventLocalDataSourceImpl(ref.watch(appDatabaseProvider));
});

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepositoryImpl(ref.watch(eventLocalDataSourceProvider));
});

final getEventsUseCaseProvider = Provider<GetEventsUseCase>((ref) {
  return GetEventsUseCase(ref.watch(eventRepositoryProvider));
});

final createEventUseCaseProvider = Provider<CreateEventUseCase>((ref) {
  return CreateEventUseCase(ref.watch(eventRepositoryProvider));
});

final updateEventUseCaseProvider = Provider<UpdateEventUseCase>((ref) {
  return UpdateEventUseCase(ref.watch(eventRepositoryProvider));
});

final deleteEventUseCaseProvider = Provider<DeleteEventUseCase>((ref) {
  return DeleteEventUseCase(ref.watch(eventRepositoryProvider));
});

final eventListNotifierProvider =
    StateNotifierProvider<EventListNotifier, AsyncValue<List<Event>>>((ref) {
      return EventListNotifier(
        getEventsUseCase: ref.watch(getEventsUseCaseProvider),
        createEventUseCase: ref.watch(createEventUseCaseProvider),
        updateEventUseCase: ref.watch(updateEventUseCaseProvider),
        deleteEventUseCase: ref.watch(deleteEventUseCaseProvider),
      );
    });

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
