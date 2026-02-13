import 'package:flutter/material.dart';

/// Celebration overlay shown when level is completed
class CelebrationOverlay extends StatefulWidget {
  final int score;
  final int completedCount;
  final int streak;
  final String completionTime;
  final VoidCallback onNextLevel;
  final VoidCallback onReplay;
  final VoidCallback onMenu;

  const CelebrationOverlay({
    super.key,
    required this.score,
    required this.completedCount,
    required this.streak,
    required this.completionTime,
    required this.onNextLevel,
    required this.onReplay,
    required this.onMenu,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    );

    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(0.7 * _fadeAnimation.value),
          child: child,
        );
      },
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6366F1),
                  Color(0xFF8B5CF6),
                  Color(0xFFA855F7),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Celebration emoji
                const Text('🎉', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),

                // Title
                const Text(
                  'Level Complete!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Stats
                _buildStatRow(
                  icon: Icons.emoji_events,
                  label: 'Score',
                  value: widget.score.toString(),
                  color: Colors.amber,
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  icon: Icons.check_circle,
                  label: 'Items Sorted',
                  value: widget.completedCount.toString(),
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  icon: Icons.local_fire_department,
                  label: 'Best Streak',
                  value: '${widget.streak}x',
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  icon: Icons.timer,
                  label: 'Time',
                  value: widget.completionTime,
                  color: Colors.lightBlue,
                ),
                const SizedBox(height: 32),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActionButton(
                      icon: Icons.home,
                      label: 'Menu',
                      color: Colors.grey,
                      onPressed: widget.onMenu,
                    ),
                    _ActionButton(
                      icon: Icons.replay,
                      label: 'Replay',
                      color: Colors.blue,
                      onPressed: widget.onReplay,
                    ),
                    _ActionButton(
                      icon: Icons.arrow_forward,
                      label: 'Next',
                      color: Colors.green,
                      onPressed: widget.onNextLevel,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Action button for celebration overlay
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Confetti particle (for animation)
class ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double rotation;
  double rotationSpeed;
  double size;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
  });
}
