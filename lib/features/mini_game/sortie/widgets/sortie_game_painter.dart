import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:logic_mathematics/features/mini_game/sortie/data/models/game_item.dart';
import 'package:logic_mathematics/features/mini_game/sortie/data/models/game_slot.dart';
import 'package:logic_mathematics/features/mini_game/sortie/data/models/tray_shape.dart';
import '../logic/sortie_game_state.dart';

/// Custom painter for rendering the game canvas
class SortieGamePainter extends CustomPainter {
  final SortieGameState gameState;
  final Map<String, ui.Image> imageCache;
  final Animation<double>? animation;

  SortieGamePainter({
    required this.gameState,
    required this.imageCache,
    this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    _drawBackground(canvas, size);

    // Draw tray shapes
    _drawTrayShapes(canvas);

    // Only draw slots if tray image is not loaded (slots are built into tray image)
    final hasTrayImage = gameState.trayShapes.any(
      (tray) => tray.assetId != null && imageCache.containsKey(tray.assetId),
    );
    if (!hasTrayImage) {
      _drawSlots(canvas);
    }

    // Draw hint if active
    if (gameState.hintActive) {
      _drawHint(canvas);
    }

    // Draw items (non-dragging first)
    for (final item in gameState.items) {
      if (!item.isDragging) {
        _drawItem(canvas, item);
      }
    }

    // Draw dragging item last (on top)
    if (gameState.draggingItem != null) {
      _drawItem(canvas, gameState.draggingItem!, isDragging: true);
    }

    // Draw game completed overlay
    if (gameState.gameCompleted) {
      _drawCompletionOverlay(canvas, size);
    }
  }

  /// Draw background
  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          gameState.currentTheme?.backgroundColor ?? const Color(0xFFF5F5DC);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  /// Draw tray shapes
  void _drawTrayShapes(Canvas canvas) {
    for (final tray in gameState.trayShapes) {
      final rect = Rect.fromLTWH(tray.x, tray.y, tray.width, tray.height);

      // Try to draw image first
      final image = imageCache[tray.assetId];
      if (image != null) {
        // Draw shadow first
        final shadowPaint = Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            rect.shift(const Offset(4, 4)),
            Radius.circular(tray.cornerRadius),
          ),
          shadowPaint,
        );
        _drawImage(canvas, image, rect);
      } else {
        // Draw shadow
        final shadowPaint = Paint()
          ..color = Colors.black.withOpacity(0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

        switch (tray.type) {
          case TrayShapeType.roundedRectangle:
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                rect.shift(const Offset(4, 4)),
                Radius.circular(tray.cornerRadius),
              ),
              shadowPaint,
            );
            break;
          default:
            canvas.drawRect(rect.shift(const Offset(4, 4)), shadowPaint);
        }

        // Draw main shape
        final paint = Paint()
          ..color = tray.color
          ..style = PaintingStyle.fill;

        switch (tray.type) {
          case TrayShapeType.rectangle:
            canvas.drawRect(rect, paint);
            break;
          case TrayShapeType.roundedRectangle:
            canvas.drawRRect(
              RRect.fromRectAndRadius(rect, Radius.circular(tray.cornerRadius)),
              paint,
            );
            // Add subtle inner glow
            final innerGlowPaint = Paint()
              ..color = Colors.white.withOpacity(0.1)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3;
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                rect.deflate(2),
                Radius.circular(tray.cornerRadius - 2),
              ),
              innerGlowPaint,
            );
            break;
          case TrayShapeType.circle:
          case TrayShapeType.oval:
            canvas.drawOval(rect, paint);
            break;
          case TrayShapeType.shelf:
            canvas.drawRRect(
              RRect.fromRectAndRadius(rect, const Radius.circular(8)),
              paint,
            );
            break;
        }
      }
    }
  }

  /// Draw slots
  void _drawSlots(Canvas canvas) {
    for (final slot in gameState.slots) {
      final rect = Rect.fromLTWH(slot.x, slot.y, slot.width, slot.height);

      // Draw slot background
      final bgPaint = Paint()
        ..color = slot.backgroundColor.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      // Draw slot border
      final borderPaint = Paint()
        ..color = slot.borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      switch (slot.shape) {
        case SlotShape.rectangle:
          canvas.drawRect(rect, bgPaint);
          canvas.drawRect(rect, borderPaint);
          break;
        case SlotShape.roundedRectangle:
          final rrect = RRect.fromRectAndRadius(
            rect,
            Radius.circular(slot.borderRadius),
          );
          canvas.drawRRect(rrect, bgPaint);
          canvas.drawRRect(rrect, borderPaint);
          break;
        case SlotShape.circle:
          canvas.drawOval(rect, bgPaint);
          canvas.drawOval(rect, borderPaint);
          break;
        case SlotShape.oval:
          canvas.drawOval(rect, bgPaint);
          canvas.drawOval(rect, borderPaint);
          break;
        case SlotShape.diamond:
          final path = _createDiamondPath(rect);
          canvas.drawPath(path, bgPaint);
          canvas.drawPath(path, borderPaint);
          break;
        case SlotShape.hexagon:
          final path = _createHexagonPath(rect);
          canvas.drawPath(path, bgPaint);
          canvas.drawPath(path, borderPaint);
          break;
        default:
          canvas.drawRect(rect, bgPaint);
          canvas.drawRect(rect, borderPaint);
      }

      // Draw slot label if available
      if (slot.label.isNotEmpty) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: slot.label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: slot.width);
        textPainter.paint(
          canvas,
          Offset(
            slot.x + (slot.width - textPainter.width) / 2,
            slot.y + slot.height + 4,
          ),
        );
      }
    }
  }

  /// Draw game item
  void _drawItem(Canvas canvas, GameItem item, {bool isDragging = false}) {
    final image = imageCache[item.assetId];
    final rect = Rect.fromLTWH(
      item.x,
      item.y,
      item.width.toDouble(),
      item.height.toDouble(),
    );

    canvas.save();

    // Apply opacity
    final opacity = isDragging ? 0.9 : item.opacity;

    // Apply rotation
    if (item.rotation != 0) {
      final center = item.center;
      canvas.translate(center.dx, center.dy);
      canvas.rotate(item.rotation);
      canvas.translate(-center.dx, -center.dy);
    }

    if (image != null) {
      final paint = Paint()..color = Colors.white.withOpacity(opacity);
      _drawImage(canvas, image, rect, paint: paint);
    } else {
      // Fallback: draw colored placeholder (no text - user needs to guess)
      final paint = Paint()
        ..color = item.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

      // Draw shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawRRect(rrect.shift(const Offset(2, 2)), shadowPaint);

      // Draw main shape
      canvas.drawRRect(rrect, paint);

      // Draw subtle border only (no text - user guesses)
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(opacity * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawRRect(rrect, borderPaint);
    }

    // Draw selection indicator if dragging
    if (isDragging) {
      final selectionPaint = Paint()
        ..color = Colors.blue.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.inflate(4), const Radius.circular(10)),
        selectionPaint,
      );
    }

    // Draw placement indicator
    if (item.isPlaced) {
      final slot = gameState.slots.firstWhere(
        (s) => s.id == item.slotId,
        orElse: () => gameState.slots.first,
      );
      final isCorrect = slot.itemId == item.id;

      final indicatorPaint = Paint()
        ..color = isCorrect ? Colors.green : Colors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.inflate(2), const Radius.circular(10)),
        indicatorPaint,
      );
    }

    canvas.restore();
  }

  /// Draw hint
  void _drawHint(Canvas canvas) {
    // Draw pulsing effect for hint item and slot
    if (gameState.hintActive) {
      // Placeholder hint visualization
      // In real implementation, use animation values for pulsing effect
    }
  }

  /// Draw completion overlay
  void _drawCompletionOverlay(Canvas canvas, Size size) {
    // Semi-transparent background
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.6);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), overlayPaint);

    // Draw celebration text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '🎉 Level Complete! 🎉',
        style: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(maxWidth: size.width - 40);
    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2, size.height / 2 - 50),
    );

    // Draw score
    final scorePainter = TextPainter(
      text: TextSpan(
        text: 'Score: ${gameState.currentScore}',
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    scorePainter.layout();
    scorePainter.paint(
      canvas,
      Offset((size.width - scorePainter.width) / 2, size.height / 2 + 20),
    );
  }

  /// Draw image to canvas
  void _drawImage(Canvas canvas, ui.Image image, Rect rect, {Paint? paint}) {
    final srcRect = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    canvas.drawImageRect(image, srcRect, rect, paint ?? Paint());
  }

  /// Create diamond path
  Path _createDiamondPath(Rect rect) {
    final path = Path();
    path.moveTo(rect.center.dx, rect.top);
    path.lineTo(rect.right, rect.center.dy);
    path.lineTo(rect.center.dx, rect.bottom);
    path.lineTo(rect.left, rect.center.dy);
    path.close();
    return path;
  }

  /// Create hexagon path
  Path _createHexagonPath(Rect rect) {
    final path = Path();
    final w = rect.width;
    final h = rect.height;
    final x = rect.left;
    final y = rect.top;

    path.moveTo(x + w * 0.25, y);
    path.lineTo(x + w * 0.75, y);
    path.lineTo(x + w, y + h * 0.5);
    path.lineTo(x + w * 0.75, y + h);
    path.lineTo(x + w * 0.25, y + h);
    path.lineTo(x, y + h * 0.5);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(SortieGamePainter oldDelegate) {
    return true; // Always repaint for smooth animations
  }
}
