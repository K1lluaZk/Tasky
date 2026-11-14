import '../../../../core/errors/failures.dart';
import '../entities/event.dart';
import '../repositories/event_repository.dart';

class UpdateEventUseCase {
  const UpdateEventUseCase(this._repository);

  final EventRepository _repository;

  Future<void> call(Event event) {
    final message = event.validationMessage;
    if (message != null) throw ValidationFailure(message);
    return _repository.updateEvent(event);
  }
}
