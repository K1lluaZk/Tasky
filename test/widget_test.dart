import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/app/app.dart';

void main() {
  testWidgets('MobileOrganizerApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MobileOrganizerApp(),
      ),
    );

    // Initial frame render
    await tester.pump();

    // Verify AppBar with title 'Tareas' is rendered
    expect(find.text('Tareas'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
