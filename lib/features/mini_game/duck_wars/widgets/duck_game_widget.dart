import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../data/assets.dart' as assets_map;
import '../logic/game_controller.dart';

/// A duck game widget with improved visuals: background, neon HUD, scanline,
/// bobbing and rotation for ducks, and a bottom gun UI to resemble the web
/// screenshot provided.
class DuckGameWidget extends StatefulWidget {
  final double logicalWidth;
  final double logicalHeight;

  const DuckGameWidget({
    Key? key,
    this.logicalWidth = 360,
    this.logicalHeight = 640,
  }) : super(key: key);

  @override
  _DuckGameWidgetState createState() => _DuckGameWidgetState();
}

// Simple beam model for muzzle flashes / laser lines
class _Beam {
  final double sx, sy, ex, ey;
  final double created;
  _Beam({
    required this.sx,
    required this.sy,
    required this.ex,
    required this.ey,
    required this.created,
  });
}

class _BeamPainter extends CustomPainter {
  final List<_Beam> beams;
  final double now;
  final double sx, sy; // screen scale factors

  _BeamPainter({
    required this.beams,
    required this.now,
    required this.sx,
    required this.sy,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    // draw beams; painter does not mutate beams list (state cleared by widget ticker)
    for (var b in beams) {
      final age = now - b.created;
      if (age > 0.25) continue; // expired
      final t = (1.0 - (age / 0.25)).clamp(0.0, 1.0);
      final opacity = t;
      paint.shader =
          LinearGradient(
            colors: [
              Colors.white.withOpacity(opacity),
              Color(0xFF00F3FF).withOpacity(opacity * 0.9),
            ],
          ).createShader(
            Rect.fromPoints(
              Offset(b.sx * sx, b.sy * sy),
              Offset(b.ex * sx, b.ey * sy),
            ),
          );
      paint.strokeWidth = 4.0 * t;
      canvas.drawLine(
        Offset(b.sx * sx, b.sy * sy),
        Offset(b.ex * sx, b.ey * sy),
        paint,
      );

      // small muzzle glow at source
      final glowPaint = Paint()..color = Color(0xFF00F3FF).withOpacity(0.6 * t);
      canvas.drawCircle(Offset(b.sx * sx, b.sy * sy), 8.0 * t, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BeamPainter old) => true;
}

class _DuckGameWidgetState extends State<DuckGameWidget>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final GameController controller;
  Duration _last = Duration.zero;
  double _time = 0.0;
  final List<_Beam> _beams = [];

  @override
  void initState() {
    super.initState();
    controller = GameController(
      logicalWidth: widget.logicalWidth,
      logicalHeight: widget.logicalHeight,
    );
    controller.start();

    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    if (_last == Duration.zero) _last = elapsed;
    final dt = (elapsed - _last).inMilliseconds / 1000.0;
    _last = elapsed;
    _time += dt;
    controller.update(dt);
    // cleanup expired beams (older than 0.3s)
    _beams.removeWhere((b) => (_time - b.created) > 0.3);
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  double _scaleX(BoxConstraints c) => c.maxWidth / widget.logicalWidth;
  double _scaleY(BoxConstraints c) => c.maxHeight / widget.logicalHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sx = _scaleX(constraints);
        final sy = _scaleY(constraints);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            // convert to logical coords
            final pos = details.localPosition;
            final lx = pos.dx / sx;
            final ly = pos.dy / sy;
            final hitDuck = controller.handleTap(lx, ly);
            if (hitDuck != null) {
              // simple feedback
              ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                SnackBar(
                  content: Text('Hit! Score: ${controller.score}'),
                  duration: Duration(milliseconds: 300),
                ),
              );
            }

            // create muzzle beam from gun base to tap location (logical coords)
            final gunBaseX = widget.logicalWidth / 2;
            final gunBaseY = widget.logicalHeight - 40.0;
            final beamEx = hitDuck != null ? hitDuck.x : lx;
            final beamEy = hitDuck != null ? hitDuck.y : ly;
            _beams.add(
              _Beam(
                sx: gunBaseX,
                sy: gunBaseY,
                ex: beamEx,
                ey: beamEy,
                created: _time,
              ),
            );

            setState(() {});
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // background image (cover)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(assets_map.duckAssets['background']!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // subtle scanline moving downwards
              Positioned(
                top:
                    ((_time * 160) % widget.logicalHeight) *
                    (constraints.maxHeight / widget.logicalHeight),
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF00F3FF).withOpacity(0.22),
                        Colors.transparent,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),

              // ducks (with bobbing and rotation)
              ...controller.ducks.map((d) {
                final left = d.x * sx - d.size / 2 * sx;
                final top =
                    (d.y + sin(d.phase + _time * 2.0) * 8.0) * sy -
                    d.size / 2 * sy;
                final width = d.size * sx;
                return Positioned(
                  left: left,
                  top: top,
                  width: width,
                  height: width,
                  child: IgnorePointer(
                    child: Transform(
                      transform: Matrix4.identity()..rotateZ(d.rotation),
                      alignment: Alignment.center,
                      child: Image.network(
                        d.assetUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (c, child, progress) {
                          return child;
                        },
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.green,
                          child: Icon(Icons.bug_report, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),

              // beams painter (draw beam lines and muzzle flashes)
              Positioned.fill(
                child: CustomPaint(
                  painter: _BeamPainter(
                    beams: _beams,
                    now: _time,
                    sx: sx,
                    sy: sy,
                  ),
                ),
              ),

              // Top HUD neon bar
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Color(0xFF00F3FF).withOpacity(0.25),
                        ),
                      ),
                      child: Text(
                        'SCORE\n${controller.score}',
                        style: TextStyle(
                          color: Color(0xFF00F3FF),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(color: Color(0xFF00F3FF), blurRadius: 12),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Color(0xFF00F3FF).withOpacity(0.25),
                        ),
                      ),
                      child: Text(
                        'TIME\n${controller.timeRemaining.toInt()}',
                        style: TextStyle(
                          color: Color(0xFF00F3FF),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(color: Color(0xFF00F3FF), blurRadius: 12),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom UI: left/right arrows and center gun
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // left arrow
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Color(0xFF00F3FF).withOpacity(0.08),
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0xFF00F3FF), width: 2),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.chevron_left,
                          color: Color(0xFF00F3FF),
                        ),
                        onPressed: () {
                          controller.cycleGun(-1);
                          setState(() {});
                        },
                      ),
                    ),

                    // center gun and label
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..scale(
                                controller.lastSpawnFromLeft ? -1.0 : 1.0,
                                1.0,
                                1.0,
                              ),
                            child: Image.network(
                              assets_map.duckAssets[controller.selectedGun] ??
                                  assets_map.duckAssets['gun_plasma']!,
                              fit: BoxFit.contain,
                              errorBuilder: (c, e, s) => Container(),
                            ),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          controller.selectedGun
                              .replaceFirst('gun_', '')
                              .toUpperCase(),
                          style: TextStyle(
                            color: Color(0xFF00F3FF),
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Color(0xFF00F3FF), blurRadius: 8),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // right arrow
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Color(0xFF00F3FF).withOpacity(0.08),
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0xFF00F3FF), width: 2),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.chevron_right,
                          color: Color(0xFF00F3FF),
                        ),
                        onPressed: () {
                          controller.cycleGun(1);
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
