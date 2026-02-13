import 'dart:convert';

import 'package:logic_mathematics/cores/datas/topic_data.dart';

class QuestionAttempt {
  final String id; // unique id
  final String topicName;
  final int correct;
  final int incorrect;
  final DateTime timestamp;
  final int totalQuestions;
  final TopicKey topicKey;

  QuestionAttempt({
    required this.id,
    required this.topicName,
    required this.correct,
    required this.timestamp,
    required this.incorrect,
    required this.topicKey,
  }) : totalQuestions = correct + incorrect;

  Map<String, dynamic> toJson() => {
    'id': id,
    'topicName': topicName,
    'correct': correct,
    'timestamp': timestamp.toIso8601String(),
    'incorrect': incorrect,
    'topicKey': topicKey.name,
  };

  factory QuestionAttempt.fromJson(Map<String, dynamic> j) => QuestionAttempt(
    id: j['id'] as String,
    topicName: j['topicName'] as String,
    correct: j['correct'] as int,
    timestamp: DateTime.parse(j['timestamp'] as String).toLocal(),
    incorrect: j['incorrect'] as int,
    topicKey: TopicKey.values.firstWhere(
      (e) => e.name == j['topicName'],
      orElse: () => TopicKey.addition,
    ),
  );

  static String encodeList(List<QuestionAttempt> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());
  static List<QuestionAttempt> decodeList(String jsonStr) {
    if (jsonStr.isEmpty) return [];
    final arr = jsonDecode(jsonStr) as List<dynamic>;
    return arr
        .map((e) => QuestionAttempt.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
