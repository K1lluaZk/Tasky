import 'package:drift/drift.dart';
import 'categories_table.dart';

@DataClassName('TaskEntry')
@TableIndex(name: 'tasks_scheduled_date_idx', columns: {#scheduledDate})
@TableIndex(name: 'tasks_due_date_idx', columns: {#dueDate})
@TableIndex(name: 'tasks_status_idx', columns: {#status})
@TableIndex(name: 'tasks_category_id_idx', columns: {#categoryId})
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1)();
  TextColumn get description => text().nullable()();
  TextColumn get priority => text().withDefault(const Constant('medium'))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get categoryId => text().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get scheduledDate => text().nullable()();
  TextColumn get dueDate => text().nullable()();
  IntColumn get completedAt => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (priority IN (\'low\', \'medium\', \'high\'))',
    'CHECK (status IN (\'pending\', \'completed\', \'cancelled\'))',
  ];
}
