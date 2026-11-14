import '../../../../core/errors/failures.dart';
import '../entities/event.dart';
import '../repositories/event_repository.dart';

class CreateEventUseCase {
  const CreateEventUseCase(this._repository);

  final EventRepository _repository;

  Future<void> call(Event event) {
    _validate(event);
    return _repository.createEvent(event);
  }
}

void _validate(Event event) {
  final message = event.validationMessage;
  if (message != null) throw ValidationFailure(message);
}
