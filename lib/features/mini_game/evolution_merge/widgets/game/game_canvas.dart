import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../data/data.dart';
import '../../logic/logic.dart';
import '../items/evolution_item_widget.dart';

/// Custom painter for the game canvas
class GameCanvasPainter extends CustomPainter {
  final EvolutionGameController controller;
  final Map<String, ui.Image>? imageCache;

  GameCanvasPainter({required this.controller, this.imageCache})
    : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / GameConstants.canvasWidth;

    canvas.save();
    canvas.scale(scale);

    // Draw container
    _drawContainer(canvas);

    // Draw danger line
    _drawDangerLine(canvas);

    // Draw drop preview
    if (controller.isPlaying && controller.nextItemType != null) {
      _drawDropPreview(canvas);
    }

    canvas.restore();
  }

  void _drawContainer(Canvas canvas) {
    final containerRect = Rect.fromLTWH(
      GameConstants.containerX,
      GameConstants.containerY,
      GameConstants.containerWidth,
      GameConstants.containerHeight,
    );

    // Background
    final bgPaint = Paint()..color = GameConstants.containerBackground;
    canvas.drawRect(containerRect, bgPaint);

    // Border
    final borderPaint = Paint()
      ..color = GameConstants.containerBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = GameConstants.containerBorderWidth;
    canvas.drawRect(containerRect, borderPaint);
  }

  void _drawDangerLine(Canvas canvas) {
    final paint = Paint()
      ..color = controller.isDangerActive
          ? GameConstants.dangerLineActive
          : GameConstants.dangerLineNormal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw dashed line
    const dashWidth = 10.0;
    const dashSpace = 10.0;
    double startX = GameConstants.containerX;
    final endX = GameConstants.containerRight;
    final y = GameConstants.dangerLineY;

    while (startX < endX) {
      canvas.drawLine(
        Offset(startX, y),
        Offset((startX + dashWidth).clamp(0, endX), y),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  void _drawDropPreview(Canvas canvas) {
    final dropX = controller.state.dropX;
    final nextType = controller.nextItemType!;

    // Draw dashed aim line
    final linePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashHeight = 8.0;
    const dashSpace = 6.0;
    double currentY = GameConstants.containerY;
    final endY = GameConstants.containerBottom;

    while (currentY < endY) {
      final dashEnd = (currentY + dashHeight).clamp(0.0, endY);
      canvas.drawLine(
        Offset(dropX, currentY),
        Offset(dropX, dashEnd),
        linePaint,
      );
      currentY += dashHeight + dashSpace;
    }

    // Draw preview circle (image will be drawn by widget overlay)
    final previewPaint = Paint()
      ..color = nextType.fallbackColor.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(dropX, GameConstants.containerY - 100),
      nextType.size / 2,
      previewPaint,
    );
  }

  @override
  bool shouldRepaint(covariant GameCanvasPainter oldDelegate) => true;
}

/// Main game canvas widget
class GameCanvas extends StatelessWidget {
  final EvolutionGameController controller;
  final Widget? backgroundWidget;

  const GameCanvas({
    super.key,
    required this.controller,
    this.backgroundWidget,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / GameConstants.canvasWidth;
        final scaledHeight = GameConstants.canvasHeight * scale;

        return SizedBox(
          width: constraints.maxWidth,
          height: scaledHeight.clamp(0, constraints.maxHeight),
          child: Stack(
            children: [
              // Background
              if (backgroundWidget != null)
                Positioned.fill(child: backgroundWidget!),

              // Canvas for static elements
              Positioned.fill(
                child: CustomPaint(
                  painter: GameCanvasPainter(controller: controller),
                ),
              ),

              // Items layer (using widgets for better image handling)
              _ItemsLayer(controller: controller, scale: scale),

              // Next item preview
              _NextItemPreview(controller: controller, scale: scale),
            ],
          ),
        );
      },
    );
  }
}

/// Layer for rendering evolution items
class _ItemsLayer extends StatelessWidget {
  final EvolutionGameController controller;
  final double scale;

  const _ItemsLayer({required this.controller, required this.scale});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Stack(
          children: controller.items.map((item) {
            final type = EvolutionTypes.getType(item.typeIndex);
            final posX = item.position.x;
            final posY = item.position.y;

            return Positioned(
              left: (posX - type.size / 2) * scale,
              top: (posY - type.size / 2) * scale,
              child: EvolutionItemWidget(
                typeIndex: item.typeIndex,
                size: type.size * scale,
                angle: item.angle,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// Preview widget for the next item to drop
class _NextItemPreview extends StatelessWidget {
  final EvolutionGameController controller;
  final double scale;

  const _NextItemPreview({required this.controller, required this.scale});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.isPlaying || controller.nextItemType == null) {
          return const SizedBox.shrink();
        }

        final nextType = controller.nextItemType!;
        final dropX = controller.state.dropX;
        final previewY = GameConstants.containerY - 100;

        return Positioned(
          left: (dropX - nextType.size / 2) * scale,
          top: (previewY - nextType.size / 2) * scale,
          child: EvolutionItemWidget(
            typeIndex: controller.state.nextItemType!,
            size: nextType.size * scale,
          ),
        );
      },
    );
  }
}
