import 'package:flutter_test/flutter_test.dart';
import 'package:logic_mathematics/cores/utils/fraction_utils.dart';

void main() {
  group('Fraction Tests', () {
    test('Parse valid fractions', () {
      expect(Fraction.fromString('1/2')?.toString(), equals('1/2'));
      expect(Fraction.fromString('3/4')?.toString(), equals('3/4'));
      expect(Fraction.fromString('5')?.toString(), equals('5'));
      expect(Fraction.fromString('10/5')?.toSimplifiedString(), equals('2'));
    });

    test('Parse invalid fractions', () {
      expect(Fraction.fromString(''), isNull);
      expect(Fraction.fromString('1/0'), isNull);
      expect(Fraction.fromString('a/b'), isNull);
      expect(Fraction.fromString('1/2/3'), isNull);
    });

    test('Simplify fractions', () {
      final fraction = Fraction(4, 8);
      expect(fraction.simplify().toString(), equals('1/2'));

      final fraction2 = Fraction(15, 25);
      expect(fraction2.simplify().toString(), equals('3/5'));

      final fraction3 = Fraction(5, 1);
      expect(fraction3.simplify().toString(), equals('5'));
    });

    test('Check equality', () {
      final f1 = Fraction(1, 2);
      final f2 = Fraction(2, 4);
      final f3 = Fraction(3, 6);

      expect(f1.equals(f2), isTrue);
      expect(f1.equals(f3), isTrue);
      expect(f2.equals(f3), isTrue);
    });

    test('Arithmetic operations', () {
      final f1 = Fraction(1, 2);
      final f2 = Fraction(1, 4);

      expect((f1 + f2).toString(), equals('3/4'));
      expect((f1 - f2).toString(), equals('1/4'));
      expect((f1 * f2).toString(), equals('1/8'));
      expect((f1 / f2).toString(), equals('2'));
    });

    test('Decimal conversion', () {
      expect(Fraction(1, 2).toDecimal(), equals(0.5));
      expect(Fraction(3, 4).toDecimal(), equals(0.75));
      expect(Fraction(5, 1).toDecimal(), equals(5.0));
    });
  });

  group('FractionUtils Tests', () {
    test('Validate fractions', () {
      expect(FractionUtils.isValidFraction('1/2'), isTrue);
      expect(FractionUtils.isValidFraction('5'), isTrue);
      expect(FractionUtils.isValidFraction('3/4'), isTrue);
      expect(FractionUtils.isValidFraction('1/0'), isFalse);
      expect(FractionUtils.isValidFraction('a/b'), isFalse);
    });

    test('Check answer correctness', () {
      expect(FractionUtils.checkAnswer('1/2', '2/4'), isTrue);
      expect(FractionUtils.checkAnswer('5/5', 1), isTrue);
      expect(FractionUtils.checkAnswer('3/4', 0.75), isTrue);
      expect(FractionUtils.checkAnswer('1/2', '1/3'), isFalse);
    });

    test('Generate equivalent fractions', () {
      final equivalents = FractionUtils.generateEquivalentFractions('1/2');
      expect(equivalents, contains('2/4'));
      expect(equivalents, contains('3/6'));
      expect(equivalents, contains('4/8'));
    });

    test('Simplify string fractions', () {
      expect(FractionUtils.simplifyString('4/8'), equals('1/2'));
      expect(FractionUtils.simplifyString('10/5'), equals('2'));
      expect(FractionUtils.simplifyString('3/7'), equals('3/7'));
    });

    test('Check equality between strings', () {
      expect(FractionUtils.areEqual('1/2', '2/4'), isTrue);
      expect(FractionUtils.areEqual('5/5', '1'), isTrue);
      expect(FractionUtils.areEqual('3/4', '6/8'), isTrue);
      expect(FractionUtils.areEqual('1/2', '1/3'), isFalse);
    });
  });
}
