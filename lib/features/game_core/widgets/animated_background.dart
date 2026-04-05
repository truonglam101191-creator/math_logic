import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({
    super.key,
    this.backgroundColor = const Color(0xFFDFF7FA), // Soft game-like ambient
    this.particleColor = const Color(0xFFFFFFFF),
    this.particleCount = 15,
  });

  final Color backgroundColor;
  final Color particleColor;
  final int particleCount;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initParticles(MediaQuery.of(context).size);
    });
  }

  void _initParticles(Size size) {
    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(
        _Particle(
          x: _random.nextDouble() * size.width,
          y: _random.nextDouble() * size.height,
          speed: _random.nextDouble() * 0.5 + 0.2, // Move up speed
          radius: _random.nextDouble() * 20 + 10,
          drift: _random.nextDouble() * 0.5 - 0.25, // Horizontal drift
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: widget.backgroundColor,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          _updateParticles(size);
          return CustomPaint(
            painter: _ParticlePainter(
              particles: _particles,
              color: widget.particleColor,
            ),
          );
        },
      ),
    );
  }

  void _updateParticles(Size size) {
    for (final p in _particles) {
      p.y -= p.speed;
      p.x += p.drift;
      
      // Wrap around
      if (p.y < -p.radius * 2) {
        p.y = size.height + p.radius * 2;
        p.x = _random.nextDouble() * size.width;
      }
      if (p.x < -p.radius * 2) p.x = size.width + p.radius * 2;
      if (p.x > size.width + p.radius * 2) p.x = -p.radius * 2;
    }
  }
}

class _Particle {
  double x;
  double y;
  double speed;
  double drift;
  double radius;

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.drift,
    required this.radius,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;

  _ParticlePainter({required this.particles, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (final p in particles) {
      canvas.drawCircle(Offset(p.x, p.y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
