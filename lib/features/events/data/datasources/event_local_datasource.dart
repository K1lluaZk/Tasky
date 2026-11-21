import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';

abstract class EventLocalDataSource {
  Future<List<EventEntry>> getEvents({String? categoryId, DateTime? eventDate});
  Future<EventEntry?> getEventById(String id);
  Future<void> insertEvent(EventsCompanion event);
  Future<int> updateEvent(EventsCompanion event);
  Future<int> deleteEvent(String id);
}

class EventLocalDataSourceImpl implements EventLocalDataSource {
  const EventLocalDataSourceImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<EventEntry>> getEvents({
    String? categoryId,
    DateTime? eventDate,
  }) {
    final query = _database.select(_database.events);
    query.where((event) {
      Expression<bool> condition = const Constant(true);
      if (categoryId != null) {
        condition = condition & event.categoryId.equals(categoryId);
      }
      if (eventDate != null) {
        final day = DateTime(eventDate.year, eventDate.month, eventDate.day);
        // Construct the next local midnight so calendar-day queries remain
        // correct across daylight-saving transitions.
        final nextDay = DateTime(day.year, day.month, day.day + 1);
        final dayStart = day.millisecondsSinceEpoch;
        final dayEnd = nextDay.millisecondsSinceEpoch;
        final allDayEvent = event.eventDate.equals(_dateToIso(day));
        final timedEvent =
            event.startAt.isSmallerThanValue(dayEnd) &
            event.endAt.isBiggerThanValue(dayStart);
        condition = condition & (allDayEvent | timedEvent);
      }
      return condition;
    });
    query.orderBy([
      (event) => OrderingTerm.asc(event.eventDate),
      (event) => OrderingTerm.asc(event.startAt),
    ]);
    return query.get();
  }

  @override
  Future<EventEntry?> getEventById(String id) => (_database.select(
    _database.events,
  )..where((event) => event.id.equals(id))).getSingleOrNull();

  @override
  Future<void> insertEvent(EventsCompanion event) =>
      _database.into(_database.events).insert(event);

  @override
  Future<int> updateEvent(EventsCompanion event) => (_database.update(
    _database.events,
  )..where((row) => row.id.equals(event.id.value))).write(event);

  @override
  Future<int> deleteEvent(String id) => (_database.delete(
    _database.events,
  )..where((event) => event.id.equals(id))).go();
}

String _dateToIso(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
