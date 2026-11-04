import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'tables/categories_table.dart';
import 'tables/events_table.dart';
import 'tables/tasks_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Categories, Tasks, Events])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
      onCreate: (m) async {
        await m.createAll();

        // Seed initial default categories
        final now = DateTime.now().millisecondsSinceEpoch;
        const uuid = Uuid();

        final defaultCategories = [
          CategoriesCompanion.insert(
            id: uuid.v4(),
            name: 'Estudios',
            color: '#2196F3',
            isDefault: const Value(true),
            createdAt: now,
            updatedAt: now,
          ),
          CategoriesCompanion.insert(
            id: uuid.v4(),
            name: 'Proyectos',
            color: '#4CAF50',
            isDefault: const Value(true),
            createdAt: now,
            updatedAt: now,
          ),
          CategoriesCompanion.insert(
            id: uuid.v4(),
            name: 'Personal',
            color: '#FF9800',
            isDefault: const Value(true),
            createdAt: now,
            updatedAt: now,
          ),
          CategoriesCompanion.insert(
            id: uuid.v4(),
            name: 'Otros',
            color: '#9E9E9E',
            isDefault: const Value(true),
            createdAt: now,
            updatedAt: now,
          ),
        ];

        for (final category in defaultCategories) {
          await into(categories).insert(category);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tasky_app.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
