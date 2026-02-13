import 'package:flutter/material.dart';

/// Header widget showing score and title
class GameHeader extends StatelessWidget {
  final int score;
  final int highScore;
  final String title;

  const GameHeader({
    super.key,
    required this.score,
    required this.highScore,
    this.title = 'Evolution Merge',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.brown.withOpacity(0.1), width: 2),
      ),
      child: Row(
        children: [
          // Score
          _ScoreItem(label: 'Score', value: score),

          // Title
          Expanded(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFFF9800), Color(0xFFF44336)],
              ).createShader(bounds),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // High Score
          _ScoreItem(label: 'Best', value: highScore),
        ],
      ),
    );
  }
}

class _ScoreItem extends StatelessWidget {
  final String label;
  final int value;

  const _ScoreItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            color: Colors.brown.shade300,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.brown.shade700,
          ),
        ),
      ],
    );
  }
}

/// Animated score display with pop effect
class AnimatedScoreDisplay extends StatefulWidget {
  final int score;
  final Color? color;

  const AnimatedScoreDisplay({super.key, required this.score, this.color});

  @override
  State<AnimatedScoreDisplay> createState() => _AnimatedScoreDisplayState();
}

class _AnimatedScoreDisplayState extends State<AnimatedScoreDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _displayedScore = 0;

  @override
  void initState() {
    super.initState();
    _displayedScore = widget.score;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(AnimatedScoreDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _displayedScore = widget.score;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Text(
        _displayedScore.toString(),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: widget.color ?? Colors.brown.shade700,
        ),
      ),
    );
  }
}
