import 'package:logic_mathematics/cores/enum/enum_difficulty_type.dart';
import 'package:logic_mathematics/cores/enum/enum_question_type.dart';

class MathQuestion {
  final String question;
  final dynamic answer;
  final List<dynamic> choicesAnswer;
  dynamic userAnswers;
  bool correct;
  final QuestionType type;
  final List<String>? choices;
  final List<String>? blanks;
  final Difficulty difficulty;
  bool isBuy = false;

  MathQuestion(
    this.question,
    this.answer, {
    this.type = QuestionType.simple,
    this.choices,
    this.blanks,
    this.difficulty = Difficulty.easy,
    this.userAnswers = null,
    this.correct = false,
    required this.choicesAnswer,
  });
}
