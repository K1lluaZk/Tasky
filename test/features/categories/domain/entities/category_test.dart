import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/features/categories/domain/entities/category.dart';

void main() {
  group('Category Entity Tests', () {
    final now = DateTime.now();

    test('isValidHexColor validates hex format correctly', () {
      expect(Category.isValidHexColor('#2196F3'), isTrue);
      expect(Category.isValidHexColor('#4CAF50'), isTrue);
      expect(Category.isValidHexColor('#FF9800'), isTrue);
      expect(Category.isValidHexColor('#FF2196F3'), isTrue); // 8-digit ARGB

      expect(Category.isValidHexColor('2196F3'), isFalse); // Missing '#'
      expect(Category.isValidHexColor('#123'), isFalse); // Too short
      expect(Category.isValidHexColor('#ZZZZZZ'), isFalse); // Invalid chars
      expect(Category.isValidHexColor('   '), isFalse);
    });

    test('colorValue extracts 32-bit ARGB integer accurately', () {
      final category = Category(
        id: '1',
        name: 'Estudios',
        color: '#2196F3',
        createdAt: now,
        updatedAt: now,
      );

      expect(category.colorValue, 0xFF2196F3);
    });

    test('copyWith and value equality work as expected', () {
      final original = Category(
        id: 'cat-1',
        name: 'Personal',
        color: '#FF9800',
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      );

      final identicalCat = Category(
        id: 'cat-1',
        name: 'Personal',
        color: '#FF9800',
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(original, equals(identicalCat));
      expect(original.hashCode, equals(identicalCat.hashCode));

      final modified = original.copyWith(name: 'Proyectos', color: '#4CAF50');
      expect(modified.name, 'Proyectos');
      expect(modified.color, '#4CAF50');
      expect(modified.id, 'cat-1');
      expect(modified, isNot(equals(original)));
    });
  });
}
