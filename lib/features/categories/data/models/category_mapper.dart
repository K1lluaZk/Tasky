import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/category.dart';

extension CategoryEntryMapper on CategoryEntry {
  Category toDomain() {
    return Category(
      id: id,
      name: name,
      color: color,
      icon: icon,
      isDefault: isDefault,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
    );
  }
}

extension CategoryDomainMapper on Category {
  CategoriesCompanion toCompanion() {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name.trim()),
      color: Value(color.trim()),
      icon: Value(icon?.trim()),
      isDefault: Value(isDefault),
      createdAt: Value(createdAt.millisecondsSinceEpoch),
      updatedAt: Value(updatedAt.millisecondsSinceEpoch),
    );
  }
}
