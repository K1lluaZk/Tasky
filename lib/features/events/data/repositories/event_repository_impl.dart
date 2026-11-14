import '../../../../core/errors/failures.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_local_datasource.dart';
import '../models/event_mapper.dart';

class EventRepositoryImpl implements EventRepository {
  const EventRepositoryImpl(this._localDataSource);

  final EventLocalDataSource _localDataSource;

  @override
  Future<void> createEvent(Event event) async {
    _validate(event);
    try {
      await _localDataSource.insertEvent(event.toCompanion());
    } catch (error) {
      if (error is Failure) rethrow;
      throw DatabaseFailure(
        'Error al crear el evento en la base de datos.',
        error,
      );
    }
  }

  @override
  Future<void> updateEvent(Event event) async {
    _validate(event);
    try {
      final updated = await _localDataSource.updateEvent(event.toCompanion());
      if (updated == 0) {
        throw const NotFoundFailure('No se encontró el evento a actualizar.');
      }
    } catch (error) {
      if (error is Failure) rethrow;
      throw DatabaseFailure(
        'Error al actualizar el evento en la base de datos.',
        error,
      );
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    try {
      final deleted = await _localDataSource.deleteEvent(id);
      if (deleted == 0) {
        throw const NotFoundFailure('No se encontró el evento a eliminar.');
      }
    } catch (error) {
      if (error is Failure) rethrow;
      throw DatabaseFailure(
        'Error al eliminar el evento en la base de datos.',
        error,
      );
    }
  }

  @override
  Future<Event?> getEventById(String id) async {
    try {
      return (await _localDataSource.getEventById(id))?.toDomain();
    } catch (error) {
      if (error is Failure) rethrow;
      throw DatabaseFailure('Error al consultar el evento por ID.', error);
    }
  }

  @override
  Future<List<Event>> getEvents({
    String? categoryId,
    DateTime? eventDate,
  }) async {
    try {
      final events = await _localDataSource.getEvents(
        categoryId: categoryId,
        eventDate: eventDate,
      );
      return events.map((event) => event.toDomain()).toList();
    } catch (error) {
      if (error is Failure) rethrow;
      throw DatabaseFailure('Error al consultar los eventos.', error);
    }
  }

  void _validate(Event event) {
    final message = event.validationMessage;
    if (message != null) throw ValidationFailure(message);
  }
}
