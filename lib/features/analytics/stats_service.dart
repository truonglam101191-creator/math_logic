import 'dart:async';
import 'package:logic_mathematics/cores/datas/topic_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'attempt_model.dart';
import 'package:uuid/uuid.dart';

enum Period { day, week, month }

class TimeSeriesPoint {
  final String label;
  final int total;
  final int correct;

  TimeSeriesPoint({
    required this.label,
    required this.total,
    required this.correct,
  });
}

class StatsService {
  static final StatsService _instance = StatsService._internal();
  factory StatsService() => _instance;
  StatsService._internal();

  static const _storageKey = 'question_attempts_v1';
  final _uuid = const Uuid();
  List<QuestionAttempt> _cache = [];

  Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_storageKey) ?? '';
    _cache = raw.isEmpty ? [] : QuestionAttempt.decodeList(raw);
  }

  Future<void> _persist() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_storageKey, QuestionAttempt.encodeList(_cache));
  }

  Future<String> recordAttempt({
    required String topicName,
    required int correct,
    required int incorrect,
    required TopicKey topicKey,
    DateTime? at,
    String? idAttemp,
  }) async {
    if (idAttemp != null && idAttemp.isNotEmpty) {
      _cache.removeWhere((element) => element.id == idAttemp);
      final when = (at ?? DateTime.now()).toUtc();
      final attempt = QuestionAttempt(
        id: idAttemp,
        topicName: topicName,
        correct: correct,
        timestamp: when,
        incorrect: incorrect,
        topicKey: topicKey,
      );
      _cache.add(attempt);
      await _persist();
      return idAttemp;
    } else {
      final when = (at ?? DateTime.now()).toUtc();
      final attempt = QuestionAttempt(
        id: _uuid.v4(),
        topicName: topicName,
        correct: correct,
        timestamp: when,
        incorrect: incorrect,
        topicKey: topicKey,
      );
      _cache.add(attempt);
      await _persist();
      return attempt.id;
    }
  }

  Future<List<QuestionAttempt>> allAttempts() async {
    return _cache;
  }

  /// Returns aggregated numbers for the given range (inclusive)
  Future<Map<String, int>> summary({DateTime? from, DateTime? to}) async {
    final fromT = from ?? DateTime.fromMillisecondsSinceEpoch(0);
    final toT = to ?? DateTime.now().toUtc();
    final filtered = _cache.where((a) {
      return a.timestamp.isAfter(
            fromT.toUtc().subtract(const Duration(milliseconds: 1)),
          ) &&
          a.timestamp.isBefore(
            toT.toUtc().add(const Duration(milliseconds: 1)),
          );
    });
    final total = filtered.fold<int>(0, (sum, a) => sum + a.totalQuestions);
    final correct = filtered.fold<int>(0, (sum, a) => sum + a.correct);
    return {'total': total, 'correct': correct, 'incorrect': total - correct};
  }

  /// Produce timeseries points grouped by period
  Future<List<TimeSeriesPoint>> timeSeries({
    Period period = Period.day,
    required int steps,
    DateTime? end,
  }) async {
    final endDate = (end ?? DateTime.now()).toUtc();
    final points = <TimeSeriesPoint>[];

    for (int i = steps - 1; i >= 0; --i) {
      DateTime start;
      String label;
      if (period == Period.day) {
        final day = DateTime.utc(
          endDate.year,
          endDate.month,
          endDate.day,
        ).subtract(Duration(days: i));
        start = day;
        label = '${day.month}/${day.day}';
      } else if (period == Period.week) {
        final weekStart = DateTime.utc(endDate.year, endDate.month, endDate.day)
            .subtract(Duration(days: endDate.weekday - 1))
            .subtract(Duration(days: 7 * i));
        start = weekStart;
        label = '${weekStart.month}/${weekStart.day}';
      } else {
        // month
        final month = DateTime.utc(
          endDate.year,
          endDate.month,
          1,
        ).subtract(Duration(days: 30 * i));
        start = DateTime.utc(month.year, month.month, 1);
        label = '${start.year}-${start.month.toString().padLeft(2, '0')}';
      }

      DateTime rangeStart = start;
      DateTime rangeEnd;
      if (period == Period.day) {
        rangeEnd = rangeStart
            .add(const Duration(days: 1))
            .subtract(const Duration(milliseconds: 1));
      } else if (period == Period.week) {
        rangeEnd = rangeStart
            .add(const Duration(days: 7))
            .subtract(const Duration(milliseconds: 1));
      } else {
        rangeEnd = DateTime.utc(
          rangeStart.year,
          rangeStart.month + 1,
          1,
        ).subtract(const Duration(milliseconds: 1));
      }

      final filtered = _cache.where((a) {
        final t = a.timestamp;
        return !t.isBefore(rangeStart) && !t.isAfter(rangeEnd);
      }).toList();

      final total = filtered.length;
      final correct = filtered.fold<int>(0, (sum, a) => sum + a.correct);
      points.add(TimeSeriesPoint(label: label, total: total, correct: correct));
    }
    return points;
  }

  /// Utility: clear all attempts (for debug/testing)
  Future<void> clearAll() async {
    _cache.clear();
    await _persist();
  }
}
