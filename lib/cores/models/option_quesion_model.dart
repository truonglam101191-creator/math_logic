import 'package:logic_mathematics/cores/enum/enum_difficulty_type.dart';

class OptionQuesionModel {
  final String option;
  final int numberOfQuestions;

  OptionQuesionModel({required this.option, required this.numberOfQuestions});

  // Factory method to create an instance from a map
  factory OptionQuesionModel.fromMap(Map<String, dynamic> map) {
    return OptionQuesionModel(
      option: map['option'] ?? Difficulty.easy.name,
      numberOfQuestions: map['numberOfQuestions'] ?? 20,
    );
  }

  // Method to convert the instance to a map
  Map<String, dynamic> toMap() {
    return {'option': option, 'numberOfQuestions': numberOfQuestions};
  }

  // Method to create a copy of the instance with updated values
  OptionQuesionModel copyWith({String? option, int? numberOfQuestions}) {
    return OptionQuesionModel(
      option: option ?? this.option,
      numberOfQuestions: numberOfQuestions ?? this.numberOfQuestions,
    );
  }
}
