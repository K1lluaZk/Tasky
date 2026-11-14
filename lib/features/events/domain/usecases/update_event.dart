import '../../../../core/errors/failures.dart';
import '../entities/event.dart';
import '../repositories/event_repository.dart';

class UpdateEventUseCase {
  const UpdateEventUseCase(this._repository);

  final EventRepository _repository;

  Future<void> call(Event event) async {
    final message = event.validationMessage;
    if (message != null) throw ValidationFailure(message);
    await _repository.updateEvent(event);
  }
}
