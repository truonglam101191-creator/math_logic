import 'dart:convert';
import 'dart:math';

import 'package:logic_mathematics/cores/extentions/shared.dart';

import '../models/usage_log.dart';
import '../enum/usage_type.dart';

class UsageService {
  UsageService._private();
  static final UsageService instance = UsageService._private();

  final Map<String, UsageLog> _active = {};
  final List<UsageLog> _completed = [];

  String start(UsageType type, String title, {Map<String, dynamic>? meta}) {
    final id =
        '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}';
    final log = UsageLog(
      id: id,
      type: type,
      title: title,
      startAt: DateTime.now(),
      meta: meta,
    );
    _active[id] = log;
    return id;
  }

  Future<void> stop(String id, {Map<String, dynamic>? extraMeta}) async {
    final log = _active.remove(id);
    if (log == null) return;
    log.endAt = DateTime.now();
    // store completed log in memory
    try {
      _completed.insert(0, log);
      // keep a bounded history to avoid unbounded memory growth
      if (_completed.length > 200) {
        _completed.removeRange(200, _completed.length);
      }
    } catch (_) {}
    // persist to SharedPreferences (using Shared.instance.sharedPreferences)
    try {
      final prefs = Shared.instance.sharedPreferences;
      final key = 'usage_service_logs';
      // load existing
      final existing = prefs.getString(key);
      List<Map<String, dynamic>> arr = [];
      if (existing != null && existing.isNotEmpty) {
        try {
          final decoded = jsonDecode(existing);
          if (decoded is List) {
            arr = decoded.cast<Map<String, dynamic>>();
          }
        } catch (_) {}
      }
      // insert new at front
      arr.insert(0, log.toJson());
      // keep bounded
      if (arr.length > 200) arr = arr.sublist(0, 200);
      await prefs.setString(key, jsonEncode(arr));
    } catch (e) {
      // ignore persistence failures but print for debug
      // ignore: avoid_print
      print('USAGE_PERSIST_ERROR: $e');
    }
  }

  /// Return active (running) usage logs
  List<UsageLog> getActiveLogs() => _active.values.toList(growable: false);

  /// Return completed usage logs (most recent first)
  List<UsageLog> getCompletedLogs({int max = 50}) =>
      _completed.take(max).toList(growable: false);

  /// Return completed usage logs grouped by `title` (most recent first per group)
  Map<String, List<UsageLog>> getCompletedGroupedByTitle({int max = 200}) {
    final Map<String, List<UsageLog>> groups = {};
    for (final log in _completed.take(max)) {
      groups.putIfAbsent(log.title, () => []).add(log);
    }
    return groups;
  }

  /// Load persisted completed logs from SharedPreferences into memory
  Future<void> loadCompletedFromPrefs() async {
    try {
      final prefs = Shared.instance.sharedPreferences;
      final key = 'usage_service_logs';
      final raw = prefs.getString(key);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _completed.clear();
        for (final item in decoded) {
          try {
            if (item is Map) {
              final m = Map<String, dynamic>.from(item);
              _completed.add(UsageLog.fromJson(m));
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      // ignore
      // ignore: avoid_print
      print('USAGE_LOAD_ERROR: $e');
    }
  }

  /// Clear stored completed logs
  void clearCompleted() => _completed.clear();
}
