import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/core/errors/failures.dart';

void main() {
  group('Failure hierarchy tests', () {
    test('DatabaseFailure should retain message and cause', () {
      final cause = Exception('Disk error');
      final failure = DatabaseFailure('Error de base de datos', cause);

      expect(failure.message, 'Error de base de datos');
      expect(failure.cause, cause);
      expect(failure.toString(), contains('DatabaseFailure: Error de base de datos'));
    });

    test('ValidationFailure should retain validation message', () {
      const failure = ValidationFailure('El título no puede estar vacío');

      expect(failure.message, 'El título no puede estar vacío');
      expect(failure.cause, isNull);
    });

    test('NotFoundFailure should retain not found message', () {
      const failure = NotFoundFailure('Tarea no encontrada');

      expect(failure.message, 'Tarea no encontrada');
    });

    test('UnexpectedFailure should have default message if omitted', () {
      const failure = UnexpectedFailure();

      expect(failure.message, 'Ha ocurrido un error inesperado.');
    });

    test('Equality should hold for same runtimeType and message', () {
      const failure1 = ValidationFailure('Error A');
      const failure2 = ValidationFailure('Error A');
      const failure3 = ValidationFailure('Error B');

      expect(failure1, equals(failure2));
      expect(failure1, isNot(equals(failure3)));
    });
  });
}
