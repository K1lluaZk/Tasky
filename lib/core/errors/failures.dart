/// Base class for all failures in the application.
/// In Clean Architecture, failures represent domain-level errors that
/// can be handled gracefully by use cases and presentation layers.
abstract class Failure {
  final String message;
  final Object? cause;

  const Failure(this.message, [this.cause]);

  @override
  String toString() =>
      '$runtimeType: $message${cause != null ? ' (Cause: $cause)' : ''}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure &&
        other.runtimeType == runtimeType &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);
}

/// Represents failures originating from the local database or persistence layer.
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, [super.cause]);
}

/// Represents failures caused by domain or input validation rules
/// (e.g., empty title, invalid date ranges, invalid priority or status).
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.cause]);
}

/// Represents failures when a requested entity (task, category, event) is not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, [super.cause]);
}

/// Represents failures when an operation conflicts with existing business rules or constraints.
class ConflictFailure extends Failure {
  const ConflictFailure(super.message, [super.cause]);
}

/// Fallback failure for unhandled or unexpected exceptions.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'Ha ocurrido un error inesperado.',
    super.cause,
  ]);
}
