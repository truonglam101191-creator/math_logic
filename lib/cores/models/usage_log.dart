import 'package:logic_mathematics/cores/enum/usage_type.dart';

class UsageLog {
  final String id;
  final UsageType type;
  final String title;
  final DateTime startAt;
  DateTime? endAt;
  final Map<String, dynamic>? meta;

  UsageLog({
    required this.id,
    required this.type,
    required this.title,
    required this.startAt,
    this.endAt,
    this.meta,
  });

  int get durationMs =>
      (endAt ?? DateTime.now()).difference(startAt).inMilliseconds;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString().split('.').last,
    'title': title,
    'startAt': startAt.millisecondsSinceEpoch,
    'endAt': endAt?.millisecondsSinceEpoch,
    'meta': meta,
  };

  static UsageLog fromJson(Map<String, dynamic> json) {
    return UsageLog(
      id: json['id'] as String,
      type: UsageType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['type'] ?? ''),
        orElse: () => UsageType.practice,
      ),
      title: json['title'] as String? ?? '',
      startAt: DateTime.fromMillisecondsSinceEpoch(json['startAt'] ?? 0),
      endAt: json['endAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['endAt'])
          : null,
      meta: json['meta'] != null
          ? Map<String, dynamic>.from(json['meta'] as Map)
          : null,
    );
  }
}
