import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';
import 'package:logic_mathematics/features/analytics/attempt_model.dart';
import 'package:logic_mathematics/features/home/widgets/animated_scale_button.dart';
import 'package:logic_mathematics/features/home/widgets/expension_widget.dart';
import 'package:logic_mathematics/l10n/arb/app_localizations.dart';
import 'package:logic_mathematics/cores/widgets/ad_native_widget.dart';
import '../../analytics/stats_service.dart';
import 'package:logic_mathematics/cores/analytics/usage_service.dart';
import 'package:logic_mathematics/cores/enum/usage_type.dart';
import 'package:logic_mathematics/features/game_core/widgets/animated_background.dart';

class SummaryTab extends StatefulWidget {
  const SummaryTab({super.key, this.onPlay});

  final Function()? onPlay;

  @override
  State<SummaryTab> createState() => _SummaryTabState();
}

class _SummaryTabState extends State<SummaryTab> {
  final StatsService _svc = StatsService();
  Period _period = Period.day;
  int _steps = 7;
  List<TimeSeriesPoint> _points = [];
  int _total = 0;
  int _correct = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _svc.init();
    // load persisted usage logs
    await UsageService.instance.loadCompletedFromPrefs();
    await _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final pts = await _svc.timeSeries(period: _period, steps: _steps);
    final sum = await _svc.summary();
    setState(() {
      _points = pts;
      _total = sum['total'] ?? 0;
      _correct = sum['correct'] ?? 0;
      _loading = false;
    });
  }

  // Future<void> _addDemoData() async {
  //   // add some sample attempts across past days
  //   final now = DateTime.now();
  //   for (int d = 0; d < 14; d++) {
  //     final date = now.subtract(Duration(days: d));
  //     final attempts = 1 + (d % 4);
  //     for (int i = 0; i < attempts; i++) {
  //       final correct = (i % 2 == 0);
  //       await _svc.recordAttempt(
  //         topicId: 'basic',
  //         topicName: 'Basic Math',
  //         correct: correct,
  //         at: date,
  //       );
  //     }
  //   }
  //   await _reload();
  // }

  // helper to map DateTime weekday -> short Vietnamese label
  String _weekdayShortLabel(DateTime d) {
    const labels = {
      1: 'T2',
      2: 'T3',
      3: 'T4',
      4: 'T5',
      5: 'T6',
      6: 'T7',
      7: 'CN',
    };
    return labels[d.weekday] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    // final accuracy = _total == 0 ? 0.0 : (_correct / _total) * 100.0;
    const primary = AppColors.primaryDark;

    // // helper to produce sample heights for 7 days from _points (0..1)
    List<double> dayHeights0() {
      if (_points.isEmpty) {
        // fallback sample pattern similar to design
        return [0.6, 0.45, 0.9, 0.3, 0.2, 0.8, 1.0];
      }
      // map totals to normalized factors
      final max = _points
          .map((e) => e.total)
          .fold<int>(0, (a, b) => a > b ? a : b);
      final denom = max == 0 ? 1 : max;
      return _points.map((e) => (e.total / denom).clamp(0.05, 1.0)).toList();
    }

    final dayHeights = dayHeights0();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const AnimatedBackground(
            backgroundColor: Color(0xFFF0F8FF), 
            particleColor: Color(0x66FFFFFF),
          ),
          SafeArea(
            bottom: false,
            child: _loading
            ? const Center(child: CircularProgressIndicator(color: primary))
            : Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // header row: back, title, avatar
                        SizedBox(
                          height: 40,
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.home_nav_summary,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // trophy + title
                        Column(
                          children: [
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Container(
                                  width: 92,
                                  height: 92,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.emoji_events,
                                      size: 44,
                                      color: primary,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: -2,
                                  top: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.yellow,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(context)!.congratulations,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppLocalizations.of(
                                context,
                              ).congratulationsDescription,
                              style: const TextStyle(color: Color(0xFF608A60)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // horizontal stats cards
                        SizedBox(
                          height: 100,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _StatCard(
                                bgColor: Colors.white,
                                icon: Icons.edit_note,
                                title: AppLocalizations.of(
                                  context,
                                ).totalQuestions,
                                value: '$_total',
                                subtitle: AppLocalizations.of(context).question,
                              ),
                              const SizedBox(width: 12),
                              _StatCard(
                                bgColor: primary,
                                emphasize: true,
                                icon: Icons.check,
                                title: AppLocalizations.of(context).correct,
                                value: '$_correct',
                                subtitle: AppLocalizations.of(context).question,
                                darkText: true,
                              ),
                              const SizedBox(width: 12),
                              _StatCard(
                                bgColor: Colors.white,
                                icon: Icons.close,
                                title: AppLocalizations.of(
                                  context,
                                ).keepPracticing,
                                value: '${_total - _correct}',
                                subtitle: AppLocalizations.of(context).question,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const AdNativeWidget(),
                        const SizedBox(height: 16),

                        // activity card with bars
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey.shade300, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.activity_week,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppLocalizations.of(context)!.last_7_days,
                                style: const TextStyle(
                                  color: Color(0xFF608A60),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 140,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  spacing: 5,
                                  children: List.generate(7, (i) {
                                    final h = i < dayHeights.length
                                        ? dayHeights[i]
                                        : 0.1;
                                    return Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Builder(
                                            builder: (context) {
                                              final height = 120 * h;
                                              return Container(
                                                height: height >= 120
                                                    ? 115
                                                    : height,
                                                decoration: BoxDecoration(
                                                  color: i >= 5
                                                      ? primary
                                                      : primary.withOpacity(
                                                          0.45,
                                                        ),
                                                  borderRadius:
                                                      const BorderRadius.vertical(
                                                        top: Radius.circular(8),
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 8),
                                          // label computed from actual date (6 days ago .. today)
                                          Text(
                                            _weekdayShortLabel(
                                              DateTime.now().subtract(
                                                Duration(days: 6 - i),
                                              ),
                                            ),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF608A60),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),

                        FutureBuilder(
                          future: _svc.allAttempts(),
                          builder: (context, asyncSnapshot) {
                            final List<QuestionAttempt> list =
                                asyncSnapshot.data ?? [];
                            return list.isNotEmpty
                                ? Column(
                                    children: [
                                      const SizedBox(height: 16),
                                      // topic progress list
                                      Text(
                                        AppLocalizations.of(
                                          context,
                                        ).progress_by_topic,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ...list.map((e) {
                                        final percent = _total == 0
                                            ? 0.0
                                            : (e.correct / e.totalQuestions)
                                                  .clamp(0.0, 1.0);
                                        final percentLabel =
                                            e.totalQuestions == 0
                                            ? '0%'
                                            : '${(percent * 100).round()}%';
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 10,
                                          ),
                                          child: _TopicProgress(
                                            icon: Icons.topic,
                                            color: primary,
                                            title: e.topicName,
                                            percent: percent,
                                            percentLabel: percentLabel,
                                          ),
                                        );
                                      }),
                                    ],
                                  )
                                : SizedBox();
                          },
                        ),
                        // Manual usage logging UI
                        _recentUsageList(),
                      ],
                    ),
                  ),

                  // bottom fixed button
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 10,
                    child: AnimatedScaleButton(
                      onPressed: widget.onPlay,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          AppLocalizations.of(context).start,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }

  Widget _recentUsageList() {
    final groups = UsageService.instance.getCompletedGroupedByTitle(max: 200);
    if (groups.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          AppLocalizations.of(context).noRecentUsageLogs,
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 15,
      children: [
        SizedBox(),
        Text(
          AppLocalizations.of(context).recentUsage,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        for (final entry in groups.entries)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ExpensionWidget(
              title: Row(
                spacing: 5,
                children: [
                  if (entry.value.first.meta?['image'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: _buildUsageImage(entry.value.first.meta?['image']),
                    ),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    _formatMs(
                      entry.value.fold<int>(0, (s, l) => s + l.durationMs),
                    ),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  spacing: 10,
                  children: entry.value.map((l) {
                    final type = l.type.toString().split('.').last;
                    final duration = l.durationMs;
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text('- $type • ${_formatMs(duration)}'),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUsageImage(dynamic imagePath) {
    if (imagePath == null || imagePath is! String || imagePath.isEmpty) {
      return Container(
        width: 20,
        height: 20,
        color: Colors.grey.shade200,
        child: const Icon(Icons.gamepad, size: 14, color: Colors.grey),
      );
    }

    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: 20,
        height: 20,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 20,
          height: 20,
          color: Colors.grey.shade200,
          child: const Icon(Icons.gamepad, size: 14, color: Colors.grey),
        ),
      );
    }

    return Image.asset(
      imagePath,
      width: 20,
      height: 20,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: 20,
        height: 20,
        color: Colors.grey.shade200,
        child: const Icon(Icons.gamepad, size: 14, color: Colors.grey),
      ),
    );
  }

  String _formatMs(int ms) {
    if (ms <= 0) return '0s';
    final d = Duration(milliseconds: ms);
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    final parts = <String>[];
    if (days > 0) parts.add('${days}d');
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0) parts.add('${minutes}m');
    if (seconds > 0) parts.add('${seconds}s');
    return parts.join(' ');
  }
}

// Small helper widgets:

class _StatCard extends StatelessWidget {
  final Color bgColor;
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final bool darkText;
  final bool emphasize;
  const _StatCard({
    required this.bgColor,
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    this.darkText = false,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF25F425);
    final textColor = darkText ? Colors.black : Colors.black87;
    return Container(
      width: 160,
      height: 96, // cố định chiều cao để khớp ListView và tránh overflow
      padding: !emphasize
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
          : null,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: emphasize ? AppColors.primaryDark : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: emphasize ? AppColors.primaryDark : Colors.grey.shade300,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: emphasize
          ? Stack(
              children: [
                Positioned(
                  bottom: -20,
                  right: -20,
                  child: Icon(Icons.check_circle, size: 100),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize
                        .min, // vẫn dùng min để không chiếm quá nhiều
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: bgColor == primary
                                  ? Colors.white70
                                  : Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              size: 16, // giảm icon kích thước chút
                              color: bgColor == primary
                                  ? Colors.black
                                  : (darkText ? Colors.black : Colors.blue),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 11, // nhỏ hơn một chút
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Giới hạn chiều cao nhỏ hơn để tránh tràn, đồng thời co font khi cần
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 28),
                        child: FittedBox(
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.scaleDown,
                          child: Text(
                            value,
                            style: TextStyle(
                              fontSize: 16, // giảm font
                              fontWeight: FontWeight.w900,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ), // nhỏ hơn
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize:
                  MainAxisSize.min, // vẫn dùng min để không chiếm quá nhiều
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: bgColor == primary
                            ? Colors.white70
                            : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 16, // giảm icon kích thước chút
                        color: bgColor == primary
                            ? Colors.black
                            : (darkText ? Colors.black : Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 11, // nhỏ hơn một chút
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Giới hạn chiều cao nhỏ hơn để tránh tràn, đồng thời co font khi cần
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 28),
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 16, // giảm font
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ), // nhỏ hơn
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
    );
  }
}

class _TopicProgress extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final double percent;
  final String percentLabel;
  const _TopicProgress({
    required this.icon,
    required this.color,
    required this.title,
    required this.percent,
    required this.percentLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      percentLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFF0F4F0),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
