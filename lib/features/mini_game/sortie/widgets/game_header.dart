import 'package:flutter/material.dart';
import '../logic/sortie_game_state.dart';

/// Header widget showing game info (level, score, streak)
class GameHeader extends StatelessWidget {
  final SortieGameState gameState;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onHintPressed;
  final VoidCallback? onResetPressed;

  const GameHeader({
    super.key,
    required this.gameState,
    this.onMenuPressed,
    this.onHintPressed,
    this.onResetPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Menu button
            _HeaderButton(icon: Icons.menu, onPressed: onMenuPressed),
            const SizedBox(width: 8),

            // Level indicator
            _LevelBadge(
              level: gameState.currentLevel,
              maxLevels: gameState.maxLevels,
            ),

            const Spacer(),

            // Progress indicator
            _ProgressIndicator(
              completed: gameState.completedCount,
              total: gameState.totalItems,
            ),

            const Spacer(),

            // Score display
            _ScoreDisplay(
              score: gameState.currentScore,
              streak: gameState.currentStreak,
              multiplier: gameState.streakMultiplier,
            ),

            const SizedBox(width: 8),

            // Hint button
            _HeaderButton(
              icon: Icons.lightbulb_outline,
              onPressed: onHintPressed,
              color: Colors.amber,
            ),

            const SizedBox(width: 8),

            // Reset button
            _HeaderButton(
              icon: Icons.refresh,
              onPressed: onResetPressed,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

/// Header button widget
class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;

  const _HeaderButton({required this.icon, this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? Colors.grey).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color ?? Colors.grey[700], size: 24),
        ),
      ),
    );
  }
}

/// Level badge widget
class _LevelBadge extends StatelessWidget {
  final int level;
  final int maxLevels;

  const _LevelBadge({required this.level, required this.maxLevels});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            'Level $level/$maxLevels',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Progress indicator widget
class _ProgressIndicator extends StatelessWidget {
  final int completed;
  final int total;

  const _ProgressIndicator({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$completed / $total',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 80,
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? Colors.green : Colors.blue,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Score display widget
class _ScoreDisplay extends StatelessWidget {
  final int score;
  final int streak;
  final double multiplier;

  const _ScoreDisplay({
    required this.score,
    required this.streak,
    required this.multiplier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Score
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(
              score.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        // Streak and multiplier
        if (streak > 0)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department,
                color: _getStreakColor(streak),
                size: 14,
              ),
              const SizedBox(width: 2),
              Text(
                '${streak}x (${multiplier.toStringAsFixed(1)})',
                style: TextStyle(
                  fontSize: 12,
                  color: _getStreakColor(streak),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Color _getStreakColor(int streak) {
    if (streak >= 5) return Colors.red;
    if (streak >= 3) return Colors.orange;
    return Colors.amber;
  }
}
