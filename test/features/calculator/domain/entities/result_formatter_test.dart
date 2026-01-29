import 'package:flutter_test/flutter_test.dart';
import 'package:samplecalc/features/calculator/domain/entities/result_formatter.dart';

void main() {
  late ResultFormatter formatter;

  setUp(() {
    formatter = ResultFormatter();
  });

  group('ResultFormatter', () {
    group('special values - no truncation', () {
      test('Infinity displays without truncation', () {
        expect(formatter.format('Infinity'), equals('Infinity'));
      });

      test('-Infinity displays without truncation', () {
        expect(formatter.format('-Infinity'), equals('-Infinity'));
      });

      test('NaN displays without truncation', () {
        expect(formatter.format('NaN'), equals('NaN'));
      });

      test('Error displays without truncation', () {
        expect(formatter.format('Error'), equals('Error'));
      });
    });

    group('numeric results', () {
      test('formats integer result', () {
        expect(formatter.format('42'), equals('42'));
      });

      test('formats decimal result', () {
        expect(formatter.format('3.14159'), equals('3.14159'));
      });

      test('formats negative number', () {
        expect(formatter.format('-123'), equals('-123'));
      });

      test('formats zero', () {
        expect(formatter.format('0'), equals('0'));
      });
    });

    group('long numbers', () {
      test('truncates very long decimal', () {
        final result = formatter.format('3.14159265358979323846');
        expect(result.length, lessThanOrEqualTo(ResultFormatter.maxDisplayDigits));
      });

      test('handles large integer within limits', () {
        expect(formatter.format('123456789'), equals('123456789'));
      });
    });

    group('isErrorOrSpecial', () {
      test('returns true for Error', () {
        expect(formatter.isErrorOrSpecial('Error'), isTrue);
      });

      test('returns true for Infinity', () {
        expect(formatter.isErrorOrSpecial('Infinity'), isTrue);
      });

      test('returns true for -Infinity', () {
        expect(formatter.isErrorOrSpecial('-Infinity'), isTrue);
      });

      test('returns true for NaN', () {
        expect(formatter.isErrorOrSpecial('NaN'), isTrue);
      });

      test('returns false for normal number', () {
        expect(formatter.isErrorOrSpecial('42'), isFalse);
      });

      test('returns false for decimal number', () {
        expect(formatter.isErrorOrSpecial('3.14'), isFalse);
      });
    });
  });
}
