import 'dart:io';

class Fraction {
  final int numerator;
  final int denominator;

  const Fraction(this.numerator, this.denominator) : assert(denominator != 0);

  // Parse fraction from string
  static Fraction? fromString(String input) {
    final trimmed = input.trim();

    if (trimmed.isEmpty) return null;

    // Handle whole numbers
    if (!trimmed.contains('/')) {
      final number = int.tryParse(trimmed);
      if (number == null) return null;
      return Fraction(number, 1);
    }

    // Handle fractions
    final parts = trimmed.split('/');
    if (parts.length != 2) return null;

    final numerator = int.tryParse(parts[0].trim());
    final denominator = int.tryParse(parts[1].trim());

    if (numerator == null || denominator == null || denominator == 0) {
      return null;
    }

    return Fraction(numerator, denominator);
  }

  // Simplify fraction
  Fraction simplify() {
    final gcd = _greatestCommonDivisor(numerator.abs(), denominator.abs());
    return Fraction(numerator ~/ gcd, denominator ~/ gcd);
  }

  // Convert to decimal
  double toDecimal() => numerator / denominator;

  // Check if equal to another fraction
  bool equals(Fraction other) {
    final thisSimplified = simplify();
    final otherSimplified = other.simplify();
    return thisSimplified.numerator == otherSimplified.numerator &&
        thisSimplified.denominator == otherSimplified.denominator;
  }

  // Check if equal to a decimal value (with tolerance)
  bool equalsDecimal(double value, {double tolerance = 0.0001}) {
    return (toDecimal() - value).abs() < tolerance;
  }

  // String representation
  @override
  String toString() {
    if (denominator == 1) {
      return numerator.toString();
    }
    return '$numerator/$denominator';
  }

  String toSimplifiedString() {
    final simplified = simplify();
    return simplified.toString();
  }

  // Arithmetic operations
  Fraction operator +(Fraction other) {
    return Fraction(
      numerator * other.denominator + other.numerator * denominator,
      denominator * other.denominator,
    ).simplify();
  }

  Fraction operator -(Fraction other) {
    return Fraction(
      numerator * other.denominator - other.numerator * denominator,
      denominator * other.denominator,
    ).simplify();
  }

  Fraction operator *(Fraction other) {
    return Fraction(
      numerator * other.numerator,
      denominator * other.denominator,
    ).simplify();
  }

  Fraction operator /(Fraction other) {
    if (other.numerator == 0) {
      throw ArgumentError('Cannot divide by zero');
    }
    return Fraction(
      numerator * other.denominator,
      denominator * other.numerator,
    ).simplify();
  }

  @override
  bool operator ==(Object other) {
    if (other is Fraction) {
      return equals(other);
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(numerator, denominator);

  static int _greatestCommonDivisor(int a, int b) {
    while (b != 0) {
      final temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }
}

// Utility class for fraction validation and operations
class FractionUtils {
  // Validate if a string can be parsed as a fraction
  static bool isValidFraction(String input) {
    return Fraction.fromString(input) != null;
  }

  // Check if two string representations of fractions are equal
  static bool areEqual(String fraction1, String fraction2) {
    final f1 = Fraction.fromString(fraction1);
    final f2 = Fraction.fromString(fraction2);

    if (f1 == null || f2 == null) return false;

    return f1.equals(f2);
  }

  // Check if fraction string equals a decimal value
  static bool equalsDecimal(
    String fractionStr,
    double decimal, {
    double tolerance = 0.0001,
  }) {
    final fraction = Fraction.fromString(fractionStr);
    if (fraction == null) return false;

    return fraction.equalsDecimal(decimal, tolerance: tolerance);
  }

  // Simplify fraction string
  static String? simplifyString(String input) {
    final fraction = Fraction.fromString(input);
    return fraction?.toSimplifiedString();
  }

  // Check if user answer matches correct answer (supports both fractions and decimals)
  static bool checkAnswer(String userAnswer, dynamic correctAnswer) {
    final userFraction = Fraction.fromString(userAnswer);
    if (userFraction == null) return false;

    // If correct answer is a string (fraction)
    if (correctAnswer is String) {
      final correctFraction = Fraction.fromString(correctAnswer);
      if (correctFraction == null) return false;
      return userFraction.equals(correctFraction);
    }

    // If correct answer is a number
    if (correctAnswer is num) {
      return userFraction.equalsDecimal(correctAnswer.toDouble());
    }

    return false;
  }

  // Generate equivalent fractions for hints
  static List<String> generateEquivalentFractions(
    String fractionStr, {
    int count = 3,
  }) {
    final fraction = Fraction.fromString(fractionStr);
    if (fraction == null) return [];

    final simplified = fraction.simplify();
    final equivalents = <String>[];

    for (int i = 2; i <= count + 1; i++) {
      final equivalent = Fraction(
        simplified.numerator * i,
        simplified.denominator * i,
      );
      equivalents.add(equivalent.toString());
    }

    return equivalents;
  }
}

List<DateTime> getCurrentWeekDates() {
  final now = DateTime.now();
  final currentWeekday = now.weekday;

  // Tìm ngày đầu tuần (thứ 2)
  final startOfWeek = now.subtract(Duration(days: currentWeekday - 1));

  // Tạo danh sách 7 ngày từ thứ 2 đến CN
  return List.generate(7, (index) {
    return startOfWeek.add(Duration(days: index));
  });
}

// Future<Directory?> getDownloadsDirectoryX() async {
//   if (Platform.isAndroid) {
//     return await getDownloadsDirectory(); // Directory('/storage/emulated/0/Download');
//   } else if (Platform.isIOS) {
//     return await getApplicationDocumentsDirectory();
//   } else {
//     return null;
//   }
// }
