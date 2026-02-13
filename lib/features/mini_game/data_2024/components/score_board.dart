import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../managers/board.dart';

class ScoreBoard extends ConsumerWidget {
  const ScoreBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(boardManager.select((board) => board.score));
    final best = ref.watch(boardManager.select((board) => board.best));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Score(label: 'Score', score: '$score', icon: Icons.stars),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Score(label: 'Best', score: '$best', icon: Icons.emoji_events),
        ),
      ],
    );
  }
}

class Score extends StatelessWidget {
  const Score({
    Key? key,
    required this.label,
    required this.score,
    required this.icon,
    this.padding,
  }) : super(key: key);

  final String label;
  final String score;
  final IconData icon;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 2),
          Text(
            score,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24.0,
            ),
          ),
        ],
      ),
    );
  }
}
