import '../entities/event.dart';
import '../repositories/event_repository.dart';

class GetEventByIdUseCase {
  const GetEventByIdUseCase(this._repository);

  final EventRepository _repository;

  Future<Event?> call(String id) => _repository.getEventById(id);
}
