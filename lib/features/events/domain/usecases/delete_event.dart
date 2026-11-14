import '../../../../core/errors/failures.dart';
import '../repositories/event_repository.dart';

class DeleteEventUseCase {
  const DeleteEventUseCase(this._repository);

  final EventRepository _repository;

  Future<void> call(String id) async {
    if (await _repository.getEventById(id) == null) {
      throw const NotFoundFailure('No se encontró el evento a eliminar.');
    }
    await _repository.deleteEvent(id);
  }
}
