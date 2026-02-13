import 'dart:math';
import 'package:flutter/material.dart';

import '../models/arrow_model.dart';
import 'arrow_painter.dart';

class ArrowWidget extends StatelessWidget {
  const ArrowWidget({
    super.key,
    required this.arrow,
    required this.cellSize,
    required this.onTap,
  });

  final ArrowModel arrow;
  final double cellSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (arrow.state == ArrowState.cleared) {
      return const SizedBox.shrink();
    }

    final double padding = cellSize * 0.1;
    final double arrowSize = cellSize - padding * 2;

    // Cycle colors
    final colors = [
      Colors.pinkAccent,
      Colors.cyanAccent,
      Colors.greenAccent,
      Colors.amberAccent,
      Colors.purpleAccent,
    ];
    final neonColor = colors[arrow.id.hashCode % colors.length];

    return AnimatedBuilder(
      animation: Listenable.merge([
        arrow.moveController,
        arrow.shakeController,
      ]),
      builder: (context, child) {
        // --- 1. Calculate Animation/Shape Points ---
        List<Offset> animatedPoints = [];

        if (arrow.state == ArrowState.moving) {
          // Snake/Uncurling Animation
          final t = arrow.moveController.value;
          final double travelDist = 12.0; // Distance in cells to travel
          final double currentProgress = travelDist * t;

          List<Point<int>> track = [];

          // Reverse body (Tail to Head)
          track.addAll(arrow.body.reversed);

          // Extension from Head
          Point<int> head = arrow.body.first;
          int dR = 0;
          int dC = 0;
          switch (arrow.direction) {
            case ArrowDirection.up:
              dR = -1;
              break;
            case ArrowDirection.down:
              dR = 1;
              break;
            case ArrowDirection.left:
              dC = -1;
              break;
            case ArrowDirection.right:
              dC = 1;
              break;
          }

          for (int i = 1; i <= 20; i++) {
            track.add(Point(head.x + (dR * i), head.y + (dC * i)));
          }

          final int bodyLen = arrow.body.length;
          final Point<int> originHead = arrow.body.first;

          for (int i = 0; i < bodyLen; i++) {
            // Body[i] corresponds to Track[bodyLen - 1 - i]
            double trackPos = (bodyLen - 1.0 - i) + currentProgress;
            Offset p = _getTrackPoint(track, trackPos);

            animatedPoints.add(
              Offset(
                (p.dy - originHead.y).toDouble(),
                (p.dx - originHead.x).toDouble(),
              ),
            );
          }
        } else {
          // Idle / Blocked (Rigid Shape)
          final head = Point(arrow.row, arrow.col);
          animatedPoints = arrow.body.map((p) {
            return Offset((p.y - head.y).toDouble(), (p.x - head.x).toDouble());
          }).toList();
        }

        // --- 2. Calculate Wrapper Offsets (Shake only) ---
        double dx = 0;
        double dy = 0;

        if (arrow.state == ArrowState.blocked) {
          final t = arrow.shakeController.value;
          dx = sin(t * pi * 4) * (cellSize * 0.1);
        }

        // Opacity Fade Out
        double opacity = 1.0;
        if (arrow.state == ArrowState.moving) {
          final t = arrow.moveController.value;
          if (t > 0.8) opacity = 1 - ((t - 0.8) / 0.2);
        }

        double rotation = 0;
        switch (arrow.direction) {
          case ArrowDirection.right:
            rotation = 0;
            break;
          case ArrowDirection.down:
            rotation = pi / 2;
            break;
          case ArrowDirection.left:
            rotation = pi;
            break;
          case ArrowDirection.up:
            rotation = -pi / 2;
            break;
        }

        return Positioned(
          left: arrow.col * cellSize + padding + dx,
          top: arrow.row * cellSize + padding + dy,
          child: Opacity(
            opacity: opacity,
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: arrowSize,
                height: arrowSize,
                child: CustomPaint(
                  painter: ArrowPainter(
                    points: animatedPoints,
                    rotation: rotation,
                    color: neonColor,
                    cellSize: cellSize,
                    opacity: opacity,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Helper to interpolate position along the track
  Offset _getTrackPoint(List<Point<int>> track, double pos) {
    if (track.isEmpty) return Offset.zero;
    if (pos < 0) pos = 0;

    if (pos >= track.length - 1) {
      Point<int> last = track.last;
      return Offset(last.x.toDouble(), last.y.toDouble());
    }

    int idx = pos.floor();
    double t = pos - idx;

    Point<int> p1 = track[idx];
    Point<int> p2 = track[idx + 1];

    return Offset(p1.x + (p2.x - p1.x) * t, p1.y + (p2.y - p1.y) * t);
  }
}
