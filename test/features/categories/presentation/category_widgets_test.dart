import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/features/categories/domain/entities/category.dart';
import 'package:tasky/features/categories/presentation/widgets/category_badge.dart';

void main() {
  group('Category Widgets Tests', () {
    final category = Category(
      id: 'cat-1',
      name: 'Estudios',
      color: '#2196F3',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    testWidgets('CategoryBadge renders category name and color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryBadge(category: category),
          ),
        ),
      );

      expect(find.text('Estudios'), findsOneWidget);
    });

    testWidgets('CategoryBadge compact mode renders smoothly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryBadge(category: category, compact: true),
          ),
        ),
      );

      expect(find.text('Estudios'), findsOneWidget);
    });
  });
}
