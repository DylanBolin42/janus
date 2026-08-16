import 'package:flutter_test/flutter_test.dart';
import 'package:janus/services/logger_service.dart';

void main() {
  group('AppLogger', () {
    test('d logs a message without throwing', () {
      expect(() => AppLogger.d('debug message'), returnsNormally);
    });

    test('i logs a message without throwing', () {
      expect(() => AppLogger.i('info message'), returnsNormally);
    });

    test('w logs a message without throwing', () {
      expect(() => AppLogger.w('warning message'), returnsNormally);
    });

    test('e logs a message without throwing', () {
      expect(() => AppLogger.e('error message'), returnsNormally);
    });

    test('e logs with error and stackTrace without throwing', () {
      expect(
        () => AppLogger.e(
          'error message',
          error: StateError('boom'),
          stackTrace: StackTrace.current,
        ),
        returnsNormally,
      );
    });
  });
}
