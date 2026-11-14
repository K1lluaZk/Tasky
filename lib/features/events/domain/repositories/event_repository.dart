import '../entities/event.dart';

abstract class EventRepository {
  Future<List<Event>> getEvents({String? categoryId, DateTime? eventDate});
  Future<Event?> getEventById(String id);
  Future<void> createEvent(Event event);
  Future<void> updateEvent(Event event);
  Future<void> deleteEvent(String id);
}
