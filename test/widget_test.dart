import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/main.dart';

void main() {
  testWidgets('TaskyApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TaskyApp(),
      ),
    );

    expect(find.text('Tasky - Personal Organizer'), findsOneWidget);
  });
}
