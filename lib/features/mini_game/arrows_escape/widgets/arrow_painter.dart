import 'dart:math';
import 'package:flutter/material.dart';

class ArrowPainter extends CustomPainter {
  final List<Offset> points; // Absolute Body Points (0,0 is HEAD)
  final double rotation; // Orientation
  final Color color;
  final double cellSize;
  final double opacity;

  ArrowPainter({
    required this.points,
    required this.rotation,
    required this.color,
    required this.cellSize,
    this.opacity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);

    // Config: Thick "Neon Tube" look as requested
    final strokeWidth = cellSize * 0.30;

    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Strategy:
    // 1. Build Body Path (relative to Head at 0,0)
    // 2. Build Head Path (at 0,0, rotated)
    // 3. Combine? No, just draw them.
    // To make it SEAMLESS, the Body line should end exactly where the Head starts.
    // Head shape: Triangle. Base is at (0,0)? No.
    // If rotation is 0 (Right), Head tip is at (len, 0). Base is at (-len, +/-w).
    // The "Body" connects to (-len, 0).
    // So the Body Line should NOT go to (0,0). It should go to (-len, 0) rotated by 'rotation'.
    // Actually, simpler:
    // Draw the Head.
    // Draw the Body up to the Head.
    // Ensure the Head COVERS the Body end.

    final fullPath = Path();

    // Head Position (Tip of the body wire)
    // Points[0] is the Head segment position (relative to center)
    Offset headPos = Offset.zero;
    if (points.isNotEmpty) {
      headPos = Offset(points[0].dx * cellSize, points[0].dy * cellSize);
    }

    // -- BODY --
    if (points.isNotEmpty && points.length > 1) {
      final tail = points.last;
      fullPath.moveTo(tail.dx * cellSize, tail.dy * cellSize);
      for (int i = points.length - 2; i >= 0; i--) {
        final p = points[i];
        fullPath.lineTo(p.dx * cellSize, p.dy * cellSize);
      }
    }

    // -- HEAD --
    final headSize = cellSize * 0.28;
    final headOffset = cellSize * 0.05;

    // Define Head Shape pointing RIGHT (standard)
    final headShape = Path();
    headShape.moveTo(headSize + headOffset, 0); // Tip
    headShape.lineTo(-headSize * 0.4 + headOffset, -headSize * 0.8); // Back Top
    headShape.lineTo(
      -headSize * 0.1 + headOffset,
      0,
    ); // Indent (Center connection point)
    headShape.lineTo(
      -headSize * 0.4 + headOffset,
      headSize * 0.8,
    ); // Back Bottom
    headShape.close();

    // 1. Rotate Head Shape
    final matrix = Matrix4.identity()..rotateZ(rotation);
    // 2. Translate Head Shape to Head Position
    // We can do this by appending translation to matrix, or transforming then shifting
    matrix.translate(
      headPos.dx,
      headPos.dy,
    ); // Wait, order matters. Rotate then Translate?
    // Usually we want: Rotate around local origin, THEN move to position.
    // Matrix mult: T * R * v.
    // Matrix4 methods apply to CURRENT matrix?
    // .rotateZ adds rotation. .translate adds translation.
    // If we want T * R:
    // final m = Matrix4.translationValues(headPos.dx, headPos.dy, 0)..rotateZ(rotation);

    final transformMatrix = Matrix4.translationValues(headPos.dx, headPos.dy, 0)
      ..rotateZ(rotation);
    final rotatedHead = headShape.transform(transformMatrix.storage);

    // Add Head to Full Path?
    // No, Full Path is a Stroke (Wire). Head is a Fill.
    // They are different.
    // To make them seamless, the wire must ends INSIDE the head.
    // We drew the wire to (0,0).
    // The Indent of the head is at (-0.1 * size) rotated.
    // (0,0) is slightly forward of the indent.
    // So the wire overlaps the head. This is good for gap coverage.
    // PROBLEM: If we use Translucent Color, the overlap is dark.
    // SOLUTION: Draw both in ONE Pass using `Path.addPath` and fill? No, wire is stroke.
    // VISUAL TRICK: Draw the Wire. Then Draw the Head OPAQUE (solid color) on top to hide the joint?
    // Users requested Neon. Neon is translucent.
    // If we use solid, it loses the neon feel.
    // BUT: The Core is solid White/Color.
    // The Glow is separate.

    // Draw Glow (Blur)
    final glowPaint = Paint()
      ..color = color.withOpacity(opacity * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    final headGlowFill = Paint()
      ..color = color.withOpacity(opacity * 0.8)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawPath(fullPath, glowPaint);
    canvas.drawPath(rotatedHead, headGlowFill);

    // Draw Core (Solid)
    final corePaint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final headCoreFill = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    canvas.drawPath(fullPath, corePaint);
    canvas.drawPath(rotatedHead, headCoreFill);

    // Removed White Highlight to Ensure Uniform Color as requested
    /*
    final highlightStroke = ...
    */

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ArrowPainter oldDelegate) => true;
}
