import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/event.dart';

extension EventEntryMapper on EventEntry {
  Event toDomain() => Event(
    id: id,
    title: title,
    description: description,
    categoryId: categoryId,
    isAllDay: isAllDay,
    eventDate: _parseDate(eventDate),
    startAt: startAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(startAt!),
    endAt: endAt == null ? null : DateTime.fromMillisecondsSinceEpoch(endAt!),
    createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
  );
}

extension EventDomainMapper on Event {
  EventsCompanion toCompanion() => EventsCompanion(
    id: Value(id),
    title: Value(title.trim()),
    description: Value(description?.trim()),
    categoryId: Value(categoryId),
    isAllDay: Value(isAllDay),
    eventDate: Value(isAllDay ? _dateToIso(eventDate!) : null),
    startAt: Value(isAllDay ? null : startAt!.millisecondsSinceEpoch),
    endAt: Value(isAllDay ? null : endAt!.millisecondsSinceEpoch),
    createdAt: Value(createdAt.millisecondsSinceEpoch),
    updatedAt: Value(updatedAt.millisecondsSinceEpoch),
  );
}

DateTime? _parseDate(String? value) {
  if (value == null) return null;
  final date = DateTime.tryParse(value);
  return date == null ? null : DateTime(date.year, date.month, date.day);
}

String _dateToIso(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
