import 'package:drift/drift.dart';
import 'categories_table.dart';

@DataClassName('EventEntry')
@TableIndex(name: 'events_event_date_idx', columns: {#eventDate})
@TableIndex(name: 'events_start_at_idx', columns: {#startAt})
@TableIndex(name: 'events_category_id_idx', columns: {#categoryId})
class Events extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1)();
  TextColumn get description => text().nullable()();
  TextColumn get categoryId =>
      text().nullable().references(Categories, #id, onDelete: KeyAction.setNull)();
  TextColumn get eventDate => text().nullable()();
  IntColumn get startAt => integer().nullable()();
  IntColumn get endAt => integer().nullable()();
  BoolColumn get isAllDay => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'CHECK ((is_all_day = 1 AND event_date IS NOT NULL AND start_at IS NULL AND end_at IS NULL) OR (is_all_day = 0 AND event_date IS NULL AND start_at IS NOT NULL AND end_at IS NOT NULL AND end_at > start_at))',
      ];
}
