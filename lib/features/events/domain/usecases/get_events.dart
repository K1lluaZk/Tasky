import '../entities/event.dart';
import '../repositories/event_repository.dart';

class GetEventsUseCase {
  const GetEventsUseCase(this._repository);

  final EventRepository _repository;

  Future<List<Event>> call({String? categoryId, DateTime? eventDate}) =>
      _repository.getEvents(categoryId: categoryId, eventDate: eventDate);
}
